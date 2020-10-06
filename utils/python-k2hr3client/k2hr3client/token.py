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
import json

from k2hr3client.api import K2hr3Api

_TOKEN_API_REQUEST_BODY = """
{
    "auth": {
        "tenantName":      "<tenant name>"
    }
}
"""


class K2hr3Token(K2hr3Api):  # pylint: disable=too-many-instance-attributes
    """Represents K2hr3 TOKEN API. See https://k2hr3.antpick.ax/api_token.html for details.
    Simple usage:
    >>> import token
    >>> iaas_user = "demo"
    >>> iaas_project = "demo"
    >>> iaas_token = token.get_openstack_token(
            "http://10.0.2.15/identity/v3/auth/tokens",
            iaas_user, "password", iaas_project)
    >>> k2hr3_token = token.K2hr3Token("demo", iaas_token)
    >>> import http
    >>> http = http.K2hr3Http("http://10.0.2.15:18080/v1")
    >>> http.PUT(k2hr3_token)
    >>> k2hr3_token.token
    """

    __slots__ = ('_tenant', '_openstack_token', '_params', '_hdrs', '_body')

    def __init__(self, iaas_project, iaas_token):
        super().__init__("user/tokens")
        self.iaas_project = iaas_project
        self.iaas_token = iaas_token
        self.params = json.dumps({'tenantname': self._tenant})
        self.headers = {
            'Content-Type': 'application/json',
            'x-auth-token': 'U={}'.format(self._openstack_token)
        }
        python_data = json.loads(_TOKEN_API_REQUEST_BODY)
        python_data['auth']['tenantName'] = self._tenant
        self.body = json.dumps(python_data)

    def __repr__(self):
        attrs = []
        values = ""
        for attr in [
                '_tenant', '_openstack_token', '_params', '_hdrs', '_body'
        ]:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3Token ' + values + '>'

    @property  # type: ignore
    def iaas_project(self):
        """Returns the k2hr3 tenant. """
        return self._tenant

    @iaas_project.setter
    def iaas_project(self, val):  # type: ignore # noqa: F811
        """Sets the k2hr3 tenant. """
        if getattr(self, '_tenant', None) is None:
            self._tenant = val

    @property  # type: ignore
    def iaas_token(self):
        """Returns the openstack token. """
        return self._openstack_token

    @iaas_token.setter
    def iaas_token(self, val):  # type: ignore # noqa: F811
        """Sets the openstack token. """
        if getattr(self, '_openstack_token', None) is None:
            self._openstack_token = val

    def params(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the params. """
        if getattr(self, '_params', None) is None:
            self._params = val

    def headers(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the headers. """
        if getattr(self, '_hdrs', None) is None:
            self._hdrs = val

    def body(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the body. """
        if getattr(self, '_body', None) is None:
            self._body = val

    def response(self, code, url, headers, body):
        """Sets the response as is. """
        # print('code=[{}] url=[{}] headers=[{}] body=[{}]'.format(
        #     code, url, type(headers), body))
        self._resp.code = code
        self._resp.url = url
        self._resp.hdrs = headers
        self._resp.body = body

    @property
    def token(self):
        """Returns k2hr3 token. """
        python_data = json.loads(self._resp.body)
        return python_data.get('token')


class K2hr3RoleToken(K2hr3Api):  # pylint: disable=too-many-instance-attributes
    """Represents K2hr3 ROLE TOKEN API. See https://k2hr3.antpick.ax/api_role.html for details.
    """

    __slots__ = ('_r3token', '_role', '_expand')

    def __init__(self, r3token, role, expire):
        super().__init__("role/token")
        self.r3token = r3token
        self.role = role
        # path should be "role/token/$roletoken".
        self.path = "/".join([self.path, self.role])
        self.expire = expire
        self.params = {'expire': self._expire}
        self.headers = {
            'Content-Type': 'application/json',
            'x-auth-token': 'U={}'.format(self._r3token)
        }

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_r3token', '_role', '_expand']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3RoleToken ' + values + '>'

    @property  # type: ignore
    def role(self):
        """Returns the role. """
        return self._role

    @role.setter
    def role(self, val):  # type: ignore # noqa: F811
        """Sets the token. """
        if isinstance(val, str) is False:
            raise Exception('value type must be str, not {}'.format(type(val)))
        if getattr(self, '_role', None) is None:
            self._role = val

    @property  # type: ignore
    def expire(self):
        """Returns the expire. """
        return self._expire

    @expire.setter
    def expire(self, val):  # type: ignore # noqa: F811
        """Sets the expire. """
        if isinstance(val, int) is False:
            raise Exception('value type must be int, not {}'.format(type(val)))
        if getattr(self, '_expire', None) is None:
            self._expire = val

    @property  # type: ignore
    def r3token(self):
        """Returns the r3token. """
        return self._r3token

    @r3token.setter
    def r3token(self, val):  # type: ignore # noqa: F811
        """Sets the r3token. """
        if getattr(self, '_r3token', None) is None:
            self._r3token = val

    def params(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the params. """
        if getattr(self, '_params', None) is None:
            self._params = val

    def headers(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the headers. """
        if getattr(self, '_hdrs', None) is None:
            self._hdrs = val

    def body(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the body. """
        if getattr(self, '_body', None) is None:
            self._body = val

    def response(self, code, url, headers, body):
        """Sets the response as is. """
        self._resp.code = code
        self._resp.url = url
        self._resp.hdrs = headers
        self._resp.body = body

    @property
    def token(self):
        """Returns k2hr3 token. """
        python_data = json.loads(self._resp.body)
        return python_data.get('token')


class K2hr3RoleTokenList(K2hr3Api):  # pylint: disable=too-many-instance-attributes
    """Represents K2hr3 ROLE TOKEN LIST API. See https://k2hr3.antpick.ax/api_role.html for details.
    """

    __slots__ = ('_r3token', '_role', '_expand')

    def __init__(self, r3token, role, expand):
        super().__init__("role/token/list")
        self.r3token = r3token
        self.role = role
        # path should be "role/token/$roletoken".
        self.path = "/".join([self.path, self.role])
        self.expand = expand
        self.params = {'expand': self._expand}
        self.headers = {
            'Content-Type': 'application/json',
            'x-auth-token': 'U={}'.format(self._r3token)
        }

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_r3token', '_role', '_expand']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3RoleTokenList ' + values + '>'

    @property  # type: ignore
    def role(self):
        """Returns the role. """
        return self._role

    @role.setter
    def role(self, val):  # type: ignore # noqa: F811
        """Sets the role. """
        if isinstance(val, str) is False:
            raise Exception('value type must be str, not {}'.format(type(val)))
        if getattr(self, '_role', None) is None:
            self._role = val

    @property  # type: ignore
    def expand(self):
        """Returns the expand. """
        return self._expand

    @expand.setter
    def expand(self, val):  # type: ignore # noqa: F811
        """Sets the expand. """
        if isinstance(val, bool) is False:
            raise Exception('value type must be bool, not {}'.format(
                type(val)))
        if getattr(self, '_expand', None) is None:
            self._expand = val

    @property  # type: ignore
    def r3token(self):
        """Returns the r3token. """
        return self._r3token

    @r3token.setter
    def r3token(self, val):  # type: ignore # noqa: F811
        """Sets the r3token. """
        if getattr(self, '_r3token', None) is None:
            self._r3token = val

    def params(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the params. """
        if getattr(self, '_params', None) is None:
            self._params = val

    def headers(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the headers. """
        if getattr(self, '_hdrs', None) is None:
            self._hdrs = val

    def body(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the body. """
        if getattr(self, '_body', None) is None:
            self._body = val

    def response(self, code, url, headers, body):
        """Sets the response. """
        # print('code=[{}] url=[{}] headers=[{}] body=[{}]'.format(
        #     code, url, headers, body))
        self._resp.code = code
        self._resp.url = url
        self._resp.hdrs = headers
        self._resp.body = body

    def registerpath(self, roletoken):
        """Sets the registerpath. """
        python_data = json.loads(self._resp.body)
        return python_data['tokens'][roletoken]['registerpath']


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
