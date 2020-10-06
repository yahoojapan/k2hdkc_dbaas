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
import json
from pathlib import Path
import re

from k2hr3client.api import K2hr3Api

_MAX_LINE_LENGTH = 1024 * 8
_RESOURCE_API_REQUEST_BODY = """
{
    "resource":    {
        "name":    "<resource name>",
        "type":    "<data type>",
        "data":    "<resource data>",
        "keys":    {},
        "alias":    []
    }
}
"""


class K2hr3Resource(K2hr3Api):  # pylint: disable=too-many-instance-attributes
    """Represents K2hr3 RESOURCE API. See https://k2hr3.antpick.ax/api_resource.html for details.
    """

    __slots__ = ('_r3token', '_name', '_data_type', '_data', '_keys', '_alias')

    def __init__(self, r3token, name, data_type, data, keys, alias=None):  # pylint: disable=too-many-arguments
        super().__init__("resource")
        self.r3token = r3token
        self.name = name
        self.data_type = data_type
        self.set_data(data, name)
        self.keys = keys
        self.alias = alias
        # NOTE(hiwakaba)
        # 1. defines the 'put' abstractmethod in K2hr3Api class
        # 2. implements the 'put' in K2hr3Resource class
        # 3. changes the 'PUT' method in K2hr3Http class to invoke the 'put' in K2hr3Resource
        # 4. then, k2hr3client looks like python-novaclient
        self.params = {'name': self._name, 'type': self._data_type, 'data': self._data,
                       'keys': self._keys, 'alias': self._alias}
        self.headers = {'Content-Type': 'application/json',
                        'x-auth-token': 'U={}'.format(self._r3token)}
        python_data = json.loads(_RESOURCE_API_REQUEST_BODY)
        python_data['resource']['name'] = self._name
        python_data['resource']['type'] = self._data_type
        python_data['resource']['data'] = self._data
        python_data['resource']['keys'] = self._keys
        python_data['resource']['alias'] = self._alias
        self.body = json.dumps(python_data)

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_r3token', '_name', '_data_type', '_data', '_keys', '_alias']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3Resource ' + values + '>'

    @property  # type: ignore
    def alias(self):
        """Returns the alias."""
        return self._alias

    @alias.setter
    def alias(self, val):  # type: ignore # noqa: F811
        """Sets the alias."""
        if isinstance(val, list) is False:
            raise Exception('value type must be list, not {}'.format(type(val)))
        if getattr(self, '_alias', None) is None:
            self._alias = val

    @property  # type: ignore
    def keys(self):
        """Returns the datatype."""
        return self._keys

    @keys.setter
    def keys(self, val):  # type: ignore # noqa: F811
        """Sets the keys."""
        if isinstance(val, dict) is False:
            raise Exception('value type must be dict, not {}'.format(type(val)))
        if getattr(self, '_keys', None) is None:
            # CAUTION(hiwaba)
            # Only JSON(double quoted strings) is accepted.
            self._keys = json.dumps(val)

    @property  # type: ignore
    def data(self):
        """ Returns data."""
        return self._data

    def set_data(self, val, clustername):  # type: ignore # noqa: F811
        """ Sets data."""
        if getattr(self, '_data', None) is None:
            self._data = val
        if isinstance(val, Path) is False:
            self._data = val
        else:
            self._data = ""
            if val.exists() is False:
                raise Exception('path must exist, not {}'.format(val))
            if val.is_file() is False:
                raise Exception(
                    'path must be a regular file, not {}'.format(val))
            with val.open() as f:
                line_len = 0
                for line in iter(f.readline, ''):
                    # 3. replace TROVE_K2HDKC_CLUSTER_NAME with clustername
                    line = re.sub('__TROVE_K2HDKC_CLUSTER_NAME__', clustername, line)
                    line_len += len(line)
                    if line_len > _MAX_LINE_LENGTH:
                        raise Exception('data too big')
                    self._data = "".join([self._data, line])

    @property  # type: ignore
    def data_type(self):
        """Sets the data_type."""
        return self._data_type

    @data_type.setter
    def data_type(self, val):  # type: ignore # noqa: F811
        """Returns the data_type."""
        if getattr(self, '_data_type', None) is None:
            self._data_type = val

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
        """Sets the response as is."""
        # print('code=[{}] url=[{}] headers=[{}] body=[{}]'.format(code, url, headers, body))
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
