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
import argparse
import os
import sys

here = os.path.dirname(__file__)
src_dir = os.path.join(here, '..')
if os.path.exists(src_dir):
    sys.path.append(src_dir)

from k2hr3client.http import K2hr3Http  # type: ignore # pylint: disable=import-error, wrong-import-position
from k2hr3client.token import K2hr3Token  # type: ignore # pylint: disable=import-error, wrong-import-position
from k2hr3client.token import K2hr3RoleToken   # pylint: disable=import-error, wrong-import-position
from k2hr3client.token import K2hr3RoleTokenList   # pylint: disable=import-error, wrong-import-position

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='k2hr3 token api example')
    parser.add_argument('--url', dest='url', default='http://localhost:18080/v1',
                        help='k2hr3 api url')
    parser.add_argument('--project', dest='project', default='demo', help='openstack project')
    parser.add_argument('--token', dest='token', default='foobar', help='openstack token')
    args = parser.parse_args()

    # 1. Gets a k2hr3 token from the openstack token
    k2hr3_token = K2hr3Token(args.project, args.token)
    http = K2hr3Http(args.url)
    http.POST(k2hr3_token)

    # 2. Gets a k2hr3 role token from the k2hr3 token
    k2hr3_role_token = K2hr3RoleToken(
        k2hr3_token.token,
        role="k2hdkccluster",
        expire=0
    )
    http.GET(k2hr3_role_token)
    roletoken = k2hr3_role_token.token
    print("roletoken {}".format(roletoken))

    # 3. Gets a k2hr3 role token list from the k2hr3 token
    k2hr3_role_token_list = K2hr3RoleTokenList(
        k2hr3_token.token,
        role="k2hdkccluster",
        expand=True
    )
    http.GET(k2hr3_role_token_list)

    # 4. Gets the registerpath of the k2hr3 role token using the k2hr3 role token
    registerpath = k2hr3_role_token_list.registerpath(roletoken)
    print("registerpath {}".format(registerpath))
    sys.exit(0)

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
