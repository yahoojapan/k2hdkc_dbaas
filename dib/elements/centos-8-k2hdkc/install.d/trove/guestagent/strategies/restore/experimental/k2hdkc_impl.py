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

import re
from oslo_log import log as logging

from trove.common import utils
from trove.guestagent.common import operating_system
from trove.guestagent.datastore.experimental.k2hdkc import service
from trove.guestagent.strategies.restore import base

LOG = logging.getLogger(__name__)


class K2hdkcArchive(base.RestoreRunner):
    """Implementation of restore for k2hdkc.
    """

    __strategy_name__ = 'k2hdkcarchive'

    def __init__(self, storage, **kwargs):
        self._appstatus = service.K2hdkcAppStatus()
        self._app = service.K2hdkcApp(self._appstatus)
        """
        Get the filename from the swift url to restore.
        """
        is_match = re.search(r'http:/(/(.*))/(.*)?\.gz\.enc$',
                             kwargs.get('location'))
        if is_match is not None:
            self._id = re.findall(r'http:/(/(.*))/(.*)?\.gz\.enc$',
                                  kwargs.get('location'))[0][2]
        else:
            self._id = None

        kwargs.update({'restore_location': self._app.k2hdkc_data_dir})
        super().__init__(storage, **kwargs)

    def pre_restore(self):
        """Prepare the data directory for restored files.
        The directory itself is not included in the backup archive
        (i.e. the archive is rooted inside the data directory).
        This is to make sure we can always restore an old backup
        even if the standard guest agent data directory changes.
        """

        LOG.debug('Initializing a data directory.')
        operating_system.create_directory(self.restore_location,
                                          user=self._app.k2hdkc_owner,
                                          group=self._app.k2hdkc_group,
                                          force=True,
                                          as_root=True)

    def post_restore(self):
        """Updated ownership on the restored files.
        """
        LOG.debug('Updating ownership of the restored files.')
        # Owner of the files should be k2hdkc:k2hdkc.
        operating_system.chown(self.restore_location,
                               'k2hdkc',
                               'k2hdkc',
                               recursive=True,
                               force=True,
                               as_root=True)

        utils.execute('/usr/libexec/k2hdkc-snapshot', '--restore',
                      '%s' % self.restore_location, '%s' % self._id)

    @property
    def decrypt_cmd(self):
        """command to decrypt.
        """
        # Adds openssl options to avoid warings.
        if self.is_encrypted:
            return (
                'openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -salt -pass pass:%s | '
                % self.decrypt_key)
        return ()

    @property
    def base_restore_cmd(self):
        """Command to extract a backup archive into a given location.
        Attempt to preserve access modifiers on the archived files.
        """
        return 'sudo tar -xpPf - -C "%(restore_location)s"'


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
