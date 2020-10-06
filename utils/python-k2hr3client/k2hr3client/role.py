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
"""K2HR3 Python Client of Role API."""

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
import json

from k2hr3client.api import K2hr3Api

_ROLE_API_REQUEST_BODY = """
{
    "role":    {
        "name":        "<role name or yrn full path>",
        "policies":    [],
        "alias":       []
    }
}
"""


class K2hr3Role(K2hr3Api):  # pylint: disable=too-many-instance-attributes
    """Represents K2hr3 ROLE API. See https://k2hr3.antpick.ax/api_role.html for details.
    """

    __slots__ = ('_r3token', '_name', '_policies', '_alias')

    def __init__(self, r3token, name, policies, alias=None):
        super().__init__("role")
        self.r3token = r3token
        self.name = name
        self.policies = policies
        # optionals
        self.alias = alias
        self.params = {
            'name': self._name,
            'policies': self._policies,
            'alias': self._alias
        }
        self.headers = {
            'Content-Type': 'application/json',
            'x-auth-token': 'U={}'.format(self._r3token)
        }
        python_data = json.loads(_ROLE_API_REQUEST_BODY)
        python_data['role']['name'] = self._name
        python_data['role']['policies'] = self._policies
        python_data['role']['alias'] = self._alias
        self.body = json.dumps(python_data)

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_r3token', '_name', '_policies', '_alias']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3Role ' + values + '>'

    @property  # type: ignore
    def policies(self):
        """ Returns the policy."""
        return self._policies

    @policies.setter
    def policies(self, val):  # type: ignore # noqa: F811
        """ Sets the policy."""
        if isinstance(val, list) is False:
            raise Exception('value type must be list, not {}'.format(
                type(val)))
        if getattr(self, '_policies', None) is None:
            # NOTE(hiwaba)
            # Returns the json formatted string because of API requirements.
            # We should not handle the policy data as a python list because
            # After converting a python list to a json string, the data contains
            # a single quote, which is not a json data. Finally API rejects the request.
            # See https://docs.python.org/3/library/json.html for details.
            self._policies = json.dumps(val)

    @property  # type: ignore
    def alias(self):
        """Returns the alias."""
        return self._alias

    @alias.setter
    def alias(self, val):  # type: ignore # noqa: F811
        """Sets the alias."""
        if val and isinstance(val, list) is False:
            raise Exception('value type must be list, not {}'.format(type(val)))
        if getattr(self, '_alias', None) is None:
            self._alias = json.dumps(val)

    @property  # type: ignore
    def r3token(self):
        """Returns the r3token."""
        return self._r3token

    @r3token.setter
    def r3token(self, val):  # type: ignore # noqa: F811
        """Sets the r3token."""
        if getattr(self, '_r3token', None) is None:
            self._r3token = val

    @property  # type: ignore
    def name(self):
        """Returns the name."""
        return self._name

    @name.setter
    def name(self, val):  # type: ignore # noqa: F811
        """Sets the name."""
        if isinstance(val, str) is False:
            raise Exception('value type must be list, not {}'.format(type(val)))
        if getattr(self, '_name', None) is None:
            self._name = val

    def params(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the params."""
        if getattr(self, '_params', None) is None:
            self._params = val

    def headers(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the headers."""
        if getattr(self, '_hdrs', None) is None:
            self._hdrs = val

    def body(self, val):  # pylint: disable=arguments-differ, invalid-overridden-method
        """Sets the body."""
        if getattr(self, '_body', None) is None:
            self._body = val

    def response(self, code, url, headers, body):
        """ Sests the response as is."""
        self._resp.code = code
        self._resp.url = url
        self._resp.hdrs = headers
        self._resp.body = body

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
