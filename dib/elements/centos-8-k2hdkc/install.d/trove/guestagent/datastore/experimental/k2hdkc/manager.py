# -*- coding: utf-8 -*-
#
# K2HDKC DBaaS based on Trove
#
# Copyright 2020 Yahoo Japan Corporation
#
# K2HDKC DBaaS is a Database as a Service compatible with Trove which
# is DBaaS for OpenStack.
# Using K2HR3 as backend and incorporating it into Trove to provide
# DBaaS functionality. K2HDKC, K2HR3, CHMPX and K2HASH are components
# provided as AntPickax.
#
# For the full copyright and license information, please view
# the license file that was distributed with this source code.
#
# AUTHOR:   Takeshi Nakatani
# CREATE:   Mon Sep 14 2020
# REVISION:
#
"""OpenStack Clusters API guestagent client implementation."""

from oslo_log import log as logging
from trove.common import cfg
from trove.common import exception
from trove.common import utils
from trove.guestagent import backup
from trove.guestagent.datastore import manager
from trove.guestagent.datastore.experimental.k2hdkc import service
from trove.guestagent.common import operating_system
from trove.guestagent import volume
from trove.common.instance import ServiceStatuses
from trove.common.notification import EndNotification
import os.path
from pathlib import Path

CONF = cfg.CONF
K2HDKC_MANAGER = 'k2hdkc'
LOG = logging.getLogger(__name__)
SERVICE_STATUS_TIMEOUT = 60
K2HDKC_CONFIG_PARAM_DIR = '/etc/k2hdkc'


class Manager(manager.Manager):
    """OpenStack Clusters API guest-agent server implementation."""
    def __init__(self):
        """MUST be implemented."""
        super().__init__(K2HDKC_MANAGER)
        self._service_status_timeout = SERVICE_STATUS_TIMEOUT
        conf_dir = Path(K2HDKC_CONFIG_PARAM_DIR)
        if not conf_dir.exists():
            try:
                utils.execute_with_timeout(
                    "/bin/sudo mkdir -p {}".format(K2HDKC_CONFIG_PARAM_DIR),
                    shell=True)
            except exception.ProcessExecutionError:
                LOG.warning("Failure: sudo mkdir -p {}".format(
                    K2HDKC_CONFIG_PARAM_DIR))
        try:
            utils.execute_with_timeout(
                "/bin/sudo chmod 0777 {}".format(K2HDKC_CONFIG_PARAM_DIR),
                shell=True)
        except exception.ProcessExecutionError:
            LOG.warning(
                "Failure: sudo chmod 0777 {}".format(K2HDKC_CONFIG_PARAM_DIR))
        self._appstatus = service.K2hdkcAppStatus()
        self._app = service.K2hdkcApp(self._appstatus)

    @property
    def status(self):
        """MUST be implemented.

        GuestAgent periodically calls self.status.update() that
        means self._appstatus.update() should be implemented.
        """
        return self._appstatus

    #################
    # Instance related
    #################
    def do_prepare(self, context, packages, databases, memory_mb, users,
                   device_path, mount_point, backup_info, config_contents,
                   root_password, overrides, cluster_config, snapshot):
        # pylint: disable=too-many-arguments
        """MUST be implemented. trove.guestagent.datastore.
        trove.guestagent.datastore.manager calls self.do_prepare in
        trove.guestagent.datastore.manager.prepare()
        """
        LOG.debug("Starting initial configuration.")
        if device_path:
            device = volume.VolumeDevice(device_path)
            # unmount if device is already mounted
            device.unmount_device(device_path)
            device.format()
            device.mount(mount_point)
            operating_system.chown(mount_point, 'k2hdkc', 'k2hdkc', as_root=True)
            operating_system.create_directory(mount_point + '/data',
                                              'k2hdkc',
                                              'k2hdkc',
                                              force=True,
                                              as_root=True)
            operating_system.create_directory(mount_point + '/data/snapshots',
                                              'k2hdkc',
                                              'k2hdkc',
                                              force=True,
                                              as_root=True)
            LOG.debug('Mounted the volume.')

        if config_contents:
            LOG.debug("Applying configuration.")
            self._app.configuration_manager.save_configuration(config_contents)

        if overrides:
            LOG.debug("Applying self._app.update_overrides")
            self._app.update_overrides(context, overrides)

        LOG.debug("Applying _create_k2hdkc_overrides_files")
        self._create_k2hdkc_overrides_files()

        #################
        # Backup
        #################
        if not cluster_config:
            if backup_info:
                self._perform_restore(backup_info, context, mount_point)

    def update_overrides(self, context, overrides, remove=False):
        # pylint: disable=arguments-differ
        """trove.guestagent.datastore.manager invokes this method
        only if overrides defined.
        """
        LOG.debug("k2hdkc update_overrides %(overrides)s",
                  {'overrides': overrides})
        if remove:
            self._app.remove_overrides()
        else:
            self._app.update_overrides(context, overrides, remove)

        self._create_k2hdkc_overrides_files()

    def apply_overrides(self, context, overrides):
        """Configuration changes are made in the config YAML file and
        require restart, so this is a no-op.
        """

    def _create_k2hdkc_key_files(self, key, empty_is_changed=False):
        """Detects the key from the overrides.
        Returns true if the key exists in the overrides. false otherwise.
        Returns true if the empty_is_changed is true and the key is null.
        """
        result = False
        file_path = K2HDKC_CONFIG_PARAM_DIR + '/' + key
        value = self._app.get_value(key)

        current_param_value = None
        file_exist = False
        if os.path.isfile(file_path):
            file_exist = True
            with open(file_path, 'r') as override_param_file:
                current_param_value = override_param_file.read().replace(
                    '\n', '')
                if not current_param_value or len(current_param_value) == 0:
                    current_param_value = None

        if not value:
            if not current_param_value:
                if empty_is_changed:
                    result = True
            else:
                result = True

            # Remove file
            if file_exist:
                os.remove(file_path)

        else:
            if value != current_param_value:
                result = True

            # Update file
            with open(file_path, 'w') as override_param_file:
                override_param_file.write(str(value))

        return result

    def _create_k2hdkc_overrides_files(self):
        """puts values to files in /etc/k2hdkc.
        """
        is_changed = False

        if self._create_k2hdkc_key_files('cluster-name', True):
            is_changed = True

        if self._create_k2hdkc_key_files('extdata-url', True):
            is_changed = True

        if self._create_k2hdkc_key_files('chmpx-server-port', True):
            is_changed = True

        if self._create_k2hdkc_key_files('chmpx-server-ctlport', True):
            is_changed = True

        if self._create_k2hdkc_key_files('chmpx-slave-ctlport', True):
            is_changed = True

        if is_changed:
            try:
                utils.execute_with_timeout(
                    "/bin/sudo /usr/bin/systemctl restart k2hdkc-trove",
                    shell=True,
                    timeout=60)
            except exception.ProcessExecutionError:
                LOG.warning("Failed to restart k2hdkc.")

    def post_prepare(self, context, packages, databases, memory_mb, users,
                     device_path, mount_point, backup_info, config_contents,
                     root_password, overrides, cluster_config, snapshot):
        """Be invoked after successful prepare.
        """
        services = [
            'chmpx-trovectl', 'k2hdkc-trovectl', 'k2hdkc-check-conf.timer'
        ]
        service_error = False
        for my_service in services:
            try:
                out, err = utils.execute_with_timeout(
                    "/usr/bin/systemctl is-active {}".format(my_service),
                    shell=True)
                LOG.debug("out=(%s) err=(%s)", out, err)
            except exception.ProcessExecutionError as exc:
                if "activating" in exc.stdout:
                    LOG.debug("k2hdkc is activating now.")
                elif "inactive" in exc.stdout:
                    out, err = utils.execute_with_timeout(
                        "sudo systemctl start {}".format(my_service),
                        shell=True)
                    LOG.debug("out=(%s) err=(%s)", out, err)
                else:
                    LOG.exception("Error getting K2HDKC status.")
                    service_error = True
        for my_service in services:
            try:
                out, err = utils.execute_with_timeout(
                    "/usr/bin/systemctl is-enabled {}".format(my_service),
                    shell=True)
                LOG.debug("out=(%s) err=(%s)", out, err)
            except exception.ProcessExecutionError as exc:
                if "disabled" in exc.stdout:
                    out, err = utils.execute_with_timeout(
                        "sudo systemctl enable {}".format(my_service),
                        shell=True)
                    LOG.debug("out=(%s) err=(%s)", out, err)
                else:
                    LOG.exception("Error getting K2HDKC status.")
                    service_error = True

        # put PREPARE_END_FILENAME in GUESTAGENT_DIR
        if service_error:
            LOG.error("Error starting k2hdkc services")
        else:
            self.status.set_ready()

    #################
    # Service related
    #################
    def restart(self, context):
        """MUST be implemented."""
        self.status.restart_db_service(service.K2HDKC_SERVICE,
                                       self._service_status_timeout)

    def stop_db(self, context, do_not_start_on_reboot=False):
        """Stop the database server.

        This function is called at:
        https://github.com/openstack/trove/blob/master/trove/guestagent/api.py#L412
        """
        LOG.debug("do_not_start_on_reboot %(do_not_start_on_reboot)s",
                  {'do_not_start_on_reboot': do_not_start_on_reboot})

        self._app.stop_db(do_not_start_on_reboot=do_not_start_on_reboot)

    ######################
    # Backup
    ######################
    def _perform_restore(self, backup_info, context, restore_location):
        try:
            backup.restore(context, backup_info, restore_location)
            if self._appstatus.is_running:
                raise RuntimeError("Cannot reset the cluster name."
                                   "The service is still running.")
            self._app.stop_db()
        except Exception as exp:
            LOG.error("backup_info[id] = %s.", backup_info['id'])
            self._app.status.set_status(ServiceStatuses.FAILED)
            raise exp
        LOG.info("Restored database successfully.")

    # pylint: disable=no-self-use
    def create_backup(self, context, backup_info):
        """ invokes the k2hdkc backup implementation
        """
        with EndNotification(context):
            backup.backup(context, backup_info)

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
