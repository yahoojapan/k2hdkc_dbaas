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
 
#
# This product includes software developed at
# The Apache Software Foundation (http://www.apache.org/).
#
# Copyright 2014 Mirantis Inc.
# All Rights Reserved.
# Copyright 2015 Tesora Inc.
# All Rights Reserved.s
#

from oslo_log import log as logging

from trove.common import exception
from trove.common.i18n import _
from trove.common import utils
from trove.guestagent.common import operating_system
from trove.guestagent.datastore.experimental.k2hdkc import service
from trove.guestagent.strategies.backup import base

LOG = logging.getLogger(__name__)


class K2hdkcArchive(base.BackupRunner):
    """Implementation of backup using the Nodetool (http://goo.gl/QtXVsM)
    utility.
    """

    # It is recommended to include the system keyspace in the backup.
    # Keeping the system keyspace will reduce the restore time
    # by avoiding need to rebuilding indexes.

    __strategy_name__ = 'k2hdkcarchive'
    _SNAPSHOT_EXTENSION = 'k2har'

    def __init__(self, filename, **kwargs):
        self._appstatus = service.K2hdkcAppStatus()
        self._app = service.K2hdkcApp(self._appstatus)
        super().__init__(filename, **kwargs)

    def _run_pre_backup(self):
        """Take snapshot(s) for all keyspaces.
        Remove existing ones first if any.
        Snapshot(s) will be stored in the data directory tree:
        <data dir>/<keyspace>/<table>/snapshots/<snapshot name>
        """
        self._remove_snapshot(self.filename)
        self._snapshot_all_keyspaces(self.filename)

        # Commonly 'self.command' gets resolved in the base constructor,
        # but we can build the full command only after having taken the
        # keyspace snapshot(s).
        self.command = self._backup_cmd + self.command

    def _run_post_backup(self):
        """Remove the created snapshot(s).
        """
        self._remove_snapshot(self.filename)

    def _remove_snapshot(self, snapshot_name):
        utils.execute('/usr/libexec/k2hdkc-snapshot', '--remove',
                      '%s' % self._app.k2hdkc_data_dir, '%s' % snapshot_name)

    def _snapshot_all_keyspaces(self, snapshot_name):
        utils.execute('/usr/libexec/k2hdkc-snapshot', '--save',
                      '%s' % self._app.k2hdkc_data_dir, '%s' % snapshot_name)

    @property
    def cmd(self):
        """Gets the command name."""
        return self.zip_cmd + self.encrypt_cmd + " -pbkdf2 -iter 100000"

    @property
    def _backup_cmd(self):
        """Command to collect and package keyspace snapshot(s).
        """
        return self._build_snapshot_package_cmd(self._app.k2hdkc_data_dir,
                                                self.filename)

    def _build_snapshot_package_cmd(self, data_dir, snapshot_name):
        """Collect all files for a given snapshot and build a package
        command for them.
        Transform the paths such that the backup can be restored simply by
        extracting the archive right to an existing data directory
        (i.e. place the root into the <data dir> and
        remove the 'snapshots/<snapshot name>' portion of the path).
        Attempt to preserve access modifiers on the archived files.
        Assert the backup is not empty as there should always be
        at least the system keyspace. Fail if there is nothing to backup.
        """
        snapshot_files = operating_system.list_files_in_directory(
            data_dir,
            recursive=True,
            include_dirs=False,
            pattern=r'.*/snapshots/%s.%s' %
            (snapshot_name, self._SNAPSHOT_EXTENSION),
            as_root=True)
        num_snapshot_files = len(snapshot_files)
        LOG.debug('Found %(num)d snapshot (*.%(ext)s) files.', {
            'num': num_snapshot_files,
            'ext': self._SNAPSHOT_EXTENSION
        })
        if num_snapshot_files > 0:
            return ('sudo tar '
                    '--transform="s#snapshots/%s/##" -cpPf - -C "%s" "%s"' %
                    (snapshot_name, data_dir, '" "'.join(snapshot_files)))

        # There should always be at least the system keyspace snapshot.
        raise exception.BackupCreationError(_("No data found."))

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
