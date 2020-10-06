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
"""An example for OpenStack Identity API."""

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
import argparse
import os
import sys
import json
import urllib.parse
import urllib.request

here = os.path.dirname(__file__)
src_dir = os.path.join(here, '..')
if os.path.exists(src_dir):
    sys.path.append(src_dir)

IDENTITY_V3_PASSWORD_AUTH_JSON_DATA = """
{
    "auth": {
        "identity": {
            "methods": [
                "password"
            ],
            "password": {
                "user": {
                    "name": "admin",
                    "domain": {
                        "name": "Default"
                    },
                    "password": "devstacker"
                }
            } }
    }
}
"""

IDENTITY_V3_TOKEN_AUTH_JSON_DATA = """
{
    "auth": {
        "identity": {
            "methods": [
                "token"
            ],
            "token": {
                "id": ""
            }
        },
        "scope": {
            "project": {
                "domain": {
                    "id": "default"
                },
                "name": ""
            }
        }
    }
}
"""

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='k2hr3 token api example')
    parser.add_argument('--url', dest='url', default='http://127.0.0.1/identity/v3/auth/tokens',
                        help='identity api url. ex) http://127.0.0.1/identity/v3/auth/tokens')
    parser.add_argument('--user', dest='user', default='demo', help='openstack user')
    parser.add_argument('--password', dest='password', default='password',
                        help='openstack user password')
    parser.add_argument('--project', dest='project', default='demo', help='openstack project')
    args = parser.parse_args()

    # unscoped token-id
    # https://docs.openstack.org/api-ref/identity/v3/index.html#password-authentication-with-unscoped-authorization
    url = args.url
    python_data = json.loads(IDENTITY_V3_PASSWORD_AUTH_JSON_DATA)
    python_data['auth']['identity']['password']['user']['name'] = args.user
    python_data['auth']['identity']['password']['user']['password'] = args.password
    headers = {'User-Agent': 'hiwkby-sample', 'Content-Type': 'application/json'}
    req = urllib.request.Request(url, json.dumps(python_data).encode('ascii'),
                                 headers, method="POST")
    with urllib.request.urlopen(req) as res:
        unscoped_token_id = dict(res.info()).get('X-Subject-Token')
        print('unscoped_token_id:[{}]'.format(unscoped_token_id))

    # scoped token-id
    # https://docs.openstack.org/api-ref/identity/v3/index.html?expanded=#token-authentication-with-scoped-authorization
    my_project_name = args.project
    python_data = json.loads(IDENTITY_V3_TOKEN_AUTH_JSON_DATA)
    python_data['auth']['identity']['token']['id'] = unscoped_token_id
    python_data['auth']['scope']['project']['name'] = my_project_name
    headers = {'User-Agent': 'hiwkby-sample', 'Content-Type': 'application/json'}
    req = urllib.request.Request(url, json.dumps(python_data).encode('ascii'),
                                 headers, method="POST")
    with urllib.request.urlopen(req) as res:
        scoped_token_id = dict(res.info()).get('X-Subject-Token')
        print('scoped_token_id:[{}]'.format(scoped_token_id))

    sys.exit(0)

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
