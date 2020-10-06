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
"""K2HR3 Python Client of Resource API."""

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
import argparse
import os
import sys
from pathlib import Path

here = os.path.dirname(__file__)
src_dir = os.path.join(here, '..')
if os.path.exists(src_dir):
    sys.path.append(src_dir)

from k2hr3client.http import K2hr3Http  # type: ignore # pylint: disable=import-error, wrong-import-position
from k2hr3client.token import K2hr3Token  # type: ignore # pylint: disable=import-error, wrong-import-position
from k2hr3client.resource import K2hr3Resource  # type: ignore # pylint: disable=import-error, wrong-import-position


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='k2hr3 token api example')
    parser.add_argument('--url', dest='url', default='http://localhost:18080/v1',
                        help='k2hr3 api url')
    parser.add_argument('--project', dest='project', default='demo', help='openstack project')
    parser.add_argument('--token', dest='token', default='foobar', help='openstack token')
    parser.add_argument('--resource', dest='resource', default='k2hdkccluster',
                        help='resource name')
    args = parser.parse_args()

    # 1. Gets a k2hr3 token from the openstack token
    k2hr3_token = K2hr3Token(args.project, args.token)
    http = K2hr3Http(args.url)
    http.POST(k2hr3_token)

    # 2. Makes a new k2hr3 resource
    k2hr3_resource = K2hr3Resource(
        k2hr3_token.token,
        name=args.resource,
        data_type='string',
        data=Path('./example_resource.txt'),
        keys={
            "cluster-name": args.resource,
            "chmpx-server-port": "8020",
            "chmpx-server-ctrlport": "8021",
            "chmpx-slave-ctrlport": "8031"
        },
        alias=[]
    )
    http.POST(k2hr3_resource)
    sys.exit(0)

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
