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
"""K2HR3 Python Client."""

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
import abc
import logging
from http.client import HTTPMessage

LOG = logging.getLogger(__name__)


class _K2hr3ApiResponse():  # pylint: disable=too-many-instance-attributes
    """
    K2hr3 Api Response.
    This class is an internal class for K2hr3Api class.
    Members of this class is only set by setter methods only one time.
    """
    def __init__(self, code=None, url=None, hdrs=None, body=None):
        # init members
        self._code = code
        self._url = url
        self._hdrs = hdrs
        self._body = body

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_hdrs', '_body', '_url', '_code']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<_K2hr3ApiResponse ' + values + '>'

    @property
    def body(self) -> str:
        """Returns body"""
        return self._body

    @body.setter
    def body(self, val: str) -> None:
        """Sets the body that may be empty."""
        if isinstance(val, str) is False:
            raise Exception("val should be str, not {}".format(type(val)))
        # if not val:
        #    raise Exception("val should not be empty")
        if getattr(self, '_body', None) is None:
            self._body = val

    @property
    def hdrs(self) -> dict:
        """Returns header"""
        return self._hdrs

    @hdrs.setter
    def hdrs(self, val: dict) -> None:
        """Sets the headers that must not be empty."""
        if isinstance(val, HTTPMessage) is False:
            raise Exception(
                "val should be http.client.HTTPMessage, not {}".format(
                    type(val)))
        if not val:
            raise Exception("val should not be empty")
        if getattr(self, '_hdrs', None) is None:
            self._hdrs = val

    @property
    def code(self) -> int:
        """Returns status code"""
        return self._code

    @code.setter
    def code(self, val: int) -> None:
        """Sets the http status code that must not be empty."""
        if isinstance(val, int) is False:
            raise Exception("val should be int, not {}".format(type(val)))
        if not val:
            raise Exception("val should not be empty")
        if getattr(self, '_code', None) is None:
            self._code = val

    @property
    def url(self) -> str:
        """Returns url"""
        return self._url

    @url.setter
    def url(self, val: str) -> None:
        """Sets the url code that must not be empty."""
        if isinstance(val, str) is False:
            raise Exception("val should be str, not {}".format(type(val)))
        if not val:
            raise Exception("val should not be empty")
        if getattr(self, '_url', None) is None:
            self._url = val


class K2hr3Api(abc.ABC):
    """Base class for K2hr3 APIs."""
    def __init__(self, path, params=None, hdrs=None, body=None):
        super().__init__()
        self.path = path
        if params is None:
            params = {}
        self._params = params
        if hdrs is None:
            hdrs = {}
        self._hdrs = hdrs
        if body is None:
            body = {}
        self._body = body
        self._resp = _K2hr3ApiResponse()

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_path', '_params', '_hdrs', '_body', '_resp']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3Api ' + values + '>'

    @property
    def path(self):
        """Sets the url path."""
        return self._path

    @path.setter
    def path(self, val):
        if isinstance(val, str) is False:
            raise Exception("path should be str")
        if getattr(self, '_path', None) is None:
            self._path = val
        else:
            LOG.info("path has changed")
            self._path = val

    @property
    def params(self):
        """Sets the url params."""
        return self._params

    # The order of these annotations seems to be important.
    @params.setter  # type: ignore
    @abc.abstractmethod
    def params(self, val):
        """Sub classes should implement this method."""

    @property
    def headers(self):
        """Returns the request headers."""
        return self._hdrs

    @headers.setter    # type: ignore
    @abc.abstractmethod
    def headers(self, val):
        """Sub classes should implement this method."""

    @property
    def body(self):
        """Returns the request body."""
        return self._body

    @body.setter    # type: ignore
    @abc.abstractmethod
    def body(self, val):
        """Sub classes should implement this method."""

    @abc.abstractmethod
    def response(self, code, url, headers, body):
        """Sub classes should implement this method."""

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
