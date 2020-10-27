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

from oslo_log import log as logging
from trove.common import cfg
from trove.common import exception
from trove.common import instance as rd_instance
from trove.common import utils
from trove.common.stream_codecs import KeyValueCodec
from trove.guestagent.common.configuration import ConfigurationManager
from trove.guestagent.datastore import service
from trove.guestagent.common import guestagent_utils

CONF = cfg.CONF
LOG = logging.getLogger(__name__)
SERVER_INI = '/etc/k2hdkc/server.ini'
K2HDKC_TROVE_INI = '/etc/k2hdkc/k2hdkc-trove.cfg'
K2HDKC_SERVICE = ['k2hdkc-trove']

# [TODO]
# At this time, the guest operating system only supports CentOS.
# Therefore, the values ??of the following variables are set,
# but if the supported OS expands in the future, please change
# the values ??variably.
OWNER = 'centos'
GROUP = 'centos'

class K2hdkcApp(object):
    """
    Handles installation and configuration of K2hdkc
    on a Trove instance.
    """
    def __init__(self, status, state_change_wait_time=None):
        LOG.debug("K2hdkcApp init")
        self._status = status
        self.k2hdkc_owner = OWNER
        self.k2hdkc_group = GROUP
        self.configuration_manager = (ConfigurationManager(
            K2HDKC_TROVE_INI,
            OWNER,
            GROUP,
            KeyValueCodec(delimiter='=',
                          comment_marker='#',
                          line_terminator='\n'),
            requires_root=True))
        self.state_change_wait_time = CONF.state_change_wait_time

    def update_overrides(self, context, overrides, remove=False):
        """ invokes the configuration_manager.apply_user_override() """
        LOG.debug(
            "update_overrides - implement as like as others(but not test)")
        if overrides:
            LOG.debug("K2hdkcApp update_overrides")
            self.configuration_manager.apply_user_override(overrides)

    def remove_overrides(self):
        """ invokes the configuration_manager.remove_user_override() """
        self.configuration_manager.remove_user_override()

    def get_value(self, key):
        """ returns the k2hdkc configuration_manager """
        return self.configuration_manager.get_value(key)

    @property
    def k2hdkc_data_dir(self):
        """ returns the k2hdkc data directory """
        return guestagent_utils.build_file_path(CONF.k2hdkc.mount_point,
                                                'data')

    @property
    def service_candidates(self):
        """ returns the k2hdkc list """
        return ['k2hdkc-trove']

    def stop_db(self, update_db=False, do_not_start_on_reboot=False):
        """ stops k2hdkc database """
        LOG.debug("stop_db - called")
        self._status.stop_db_service(self.service_candidates,
                                     self.state_change_wait_time,
                                     disable_on_boot=do_not_start_on_reboot,
                                     update_db=update_db)


class K2hdkcAppStatus(service.BaseDbStatus):  # pylint: disable=too-few-public-methods
    """
    Handles all of the status updating for the K2hdkc guest agent.
    """
    def __init__(self):
        LOG.debug("K2hdkcAppStatus::__init__")
        super().__init__()

    def _get_actual_db_status(self):  # pylint: disable=no-self-use
        """ It is called from wait_for_real_status_to_change_to of BaseDbStatus class.
        """
        LOG.debug("K2hdkcAppStatus::_get_actual_db_status")
        try:
            out, err = utils.execute_with_timeout(
                "/usr/bin/systemctl is-active k2hdkc-trove", shell=True)
            LOG.debug("out=(%s) err=(%s)", out, err)
            return rd_instance.ServiceStatuses.RUNNING
        except exception.ProcessExecutionError as exc:
            if "activating" in exc.stdout:
                LOG.debug("k2hdkc is activating now, so return running.")
                return rd_instance.ServiceStatuses.RUNNING
            elif "inactive" in exc.stdout:
                LOG.debug("k2hdkc is inactive, so return shutdown.")
                return rd_instance.ServiceStatuses.SHUTDOWN
            else:
                LOG.exception("Error getting K2HDKC status.")
                return rd_instance.ServiceStatuses.SHUTDOWN

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
