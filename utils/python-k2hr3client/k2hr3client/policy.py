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
"""K2HR3 Python Client of Policy API."""

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
import json

from k2hr3client.api import K2hr3Api

_POLICY_API_REQUEST_BODY = """
{
    "policy":    {
        "name":      "<policy name>",
        "effect":    "<allow or deny>",
        "action":    [],
        "resource":  [],
        "condition": null,
        "alias":     []
    }
}
"""


class K2hr3Policy(K2hr3Api):  # pylint: disable=too-many-instance-attributes
    """Represents K2hr3 POLICY API. See https://k2hr3.antpick.ax/api_policy.html for details.
    """

    __slots__ = ('_name', '_r3token', '_name', '_effect', '_action',
                 '_resource', '_condition', '_alias')

    def __init__(
            self,
            r3token,
            name,
            effect,
            action,
            resource=None,  # pylint: disable=too-many-arguments
            condition=None,
            alias=None):
        super().__init__("policy")
        self.r3token = r3token
        self.name = name
        self.effect = effect
        self.action = action
        # optionals
        self.resource = resource
        self.condition = condition
        self.alias = alias
        self.params = {
            'name': self._name,
            'effect': self._effect,
            'action': self._action,
            'resource': self._resource,
            'alias': self._alias
        }
        self.headers = {
            'Content-Type': 'application/json',
            'x-auth-token': 'U={}'.format(self._r3token)
        }
        python_data = json.loads(_POLICY_API_REQUEST_BODY)
        python_data['policy']['name'] = self._name
        python_data['policy']['effect'] = self._effect
        python_data['policy']['action'] = self._action
        python_data['policy']['resource'] = self._resource
        python_data['policy']['alias'] = self._alias
        self.body = json.dumps(python_data)

    def __repr__(self):
        attrs = []
        values = ""
        for attr in [
                '_r3token', '_name', '_effect', '_action', '_resource',
                'condition', '_alias'
        ]:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3Policy ' + values + '>'

    @property  # type: ignore
    def effect(self):
        """Returns the effect."""
        return self._effect

    @effect.setter
    def effect(self, val):  # type: ignore # noqa: F811
        """Sets the effect."""
        if isinstance(val, str) is False:
            raise Exception('value type must be list, not {}'.format(
                type(val)))
        if getattr(self, '_effect', None) is None:
            self._effect = val

    @property  # type: ignore
    def action(self):
        """Returns action."""
        return self._action

    @action.setter
    def action(self, val):  # type: ignore # noqa: F811
        """Sets the action."""
        if isinstance(val, list) is False:
            raise Exception('value type must be list, not {}'.format(
                type(val)))
        if getattr(self, '_action', None) is None:
            self._action = json.dumps(val)

    @property  # type: ignore
    def resource(self):
        """Returns the resource."""
        return self._resource

    @resource.setter
    def resource(self, val):  # type: ignore # noqa: F811
        """Sets the resource."""
        if val and isinstance(val, list) is False:
            raise Exception('value type must be list, not {}'.format(
                type(val)))
        if getattr(self, '_resource', None) is None:
            self._resource = json.dumps(val)

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
    def condition(self):
        """Returns the condition."""
        return self._condition

    @condition.setter
    def condition(self, val):  # type: ignore # noqa: F811
        """Sets the condition."""
        if val and isinstance(val, dict) is False:
            raise Exception('value type must be dict, not {}'.format(type(val)))
        if getattr(self, '_condition', None) is None:
            self._condition = json.dumps(val)

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
