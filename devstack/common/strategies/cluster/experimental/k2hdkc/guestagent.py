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
# AUTHOR:   Hirotaka Wakabayashi
# CREATE:   Mon Sep 14 2020
# REVISION:
#
"""OpenStack Clusters API guestagent client implementation."""

from oslo_log import log as logging
from trove.common import cfg
from trove.common import exception
from trove.common.strategies.cluster import base
from trove.guestagent import api as guest_api

LOG = logging.getLogger(__name__)
CONF = cfg.CONF


class K2hdkcGuestAgentStrategy(base.BaseGuestAgentStrategy):   # pylint: disable=too-few-public-methods
    """OpenStack Clusters API guest-agent client implementation."""

    @property
    def guest_client_class(self):
        """Return Clusters API guest-agent client implementation."""
        return K2hdkcGuestAgentAPI


class K2hdkcGuestAgentAPI(guest_api.API):   # pylint: disable=too-few-public-methods
    """OpenStack Clusters API guest-agent client implementation."""

    def cluster_complete(self):
        """Execute syncronously RPC cluster_complete command."""
        LOG.debug("Execute syncronously RPC cluster_complete command.")
        try:
            version = guest_api.API.API_BASE_VERSION
            # cluster_complete endpoint is required on GuestAgent
            return self._call("cluster_complete", self.agent_high_timeout,
                              version=version)
        except (exception.GuestError, exception.GuestTimeout) as rpc_exception:
            LOG.error("exception {}".format(rpc_exception))
            raise
        except Exception:
            LOG.error("unknown exception")
            raise

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
