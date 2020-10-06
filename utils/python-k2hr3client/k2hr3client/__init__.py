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
#
"""K2HR3 Python Client of Token API."""

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)

__author__ = 'Hirotaka Wakabayashi <hiwakaba@yahoo-corp.jp>'
__version__ = '0.0.1'

import logging
import sys

# This relies on each of the submodules having an __all__ variable.
from .api import K2hr3Api
from .http import K2hr3Http
from .policy import K2hr3Policy
from .resource import K2hr3Resource
from .role import K2hr3Role
from .token import K2hr3Token, K2hr3RoleToken, K2hr3RoleTokenList

from typing import List, Set, Dict, Tuple, Optional  # noqa: pylint: disable=unused-import

__all__ = (api.K2hr3Api, http.K2hr3Http, policy.K2hr3Policy,
           resource.K2hr3Resource, role.K2hr3Role, token.K2hr3RoleToken,
           token.K2hr3RoleTokenList, token.K2hr3Token, 'version')

LOG = logging.getLogger(__name__)

if sys.platform.startswith('win'):
    raise ImportError(r'Currently we do not test well on windows')


def version() -> str:
    """Returns a version of the package.

    :returns: version
    :rtype: str
    """
    return __version__


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
