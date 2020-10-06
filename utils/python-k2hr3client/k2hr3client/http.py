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
from enum import Enum
import logging
import re
import socket
import ssl
import time
import urllib
import urllib.parse
import urllib.request
from urllib.error import ContentTooShortError, HTTPError, URLError

LOG = logging.getLogger(__name__)


class _AgentError(Enum):
    NONE = 1
    TEMP = 2
    FATAL = 3


class K2hr3Http():
    """Sends a http/https request to the K2hr3 WebAPI."""

    __slots__ = ('_url', '_hdrs', '_timeout_seconds', '_retry_interval_seconds', '_retries', '_allow_self_signed_cert', )

    def __init__(self, url):
        super().__init__()
        self.set_url(url)
        self.headers({'User-Agent': 'K2hr3Http'})
        self._timeout_seconds = 30
        self._retry_interval_seconds = 60
        self._retries = 3
        self._allow_self_signed_cert = True

    def __repr__(self):
        attrs = []
        values = ""
        for attr in ['_url', '_hdrs', '_timeout_seconds', '_retry_interval_seconds', '_retries',
                     '_allow_self_signed_cert']:
            val = getattr(self, attr, None)
            if val:
                attrs.append((attr, repr(val)))
                values = ', '.join(['%s=%s' % i for i in attrs])
        return '<K2hr3Http ' + values + '>'

    @property
    def url(self):
        """Returns the url."""
        return self._url

    def set_url(self, value):
        """Sets the url."""
        if isinstance(value, str) is False:
            raise Exception("url should be str, not {}".format(type(value)))
        # scheme
        try:
            scheme, url_string = value.split('://', maxsplit=2)
        except ValueError as error:
            raise Exception(
                'scheme should contain ://, not {}'.format(value)) from error
        if scheme not in ('http', 'https'):
            raise Exception(
                'scheme should be http or http, not {}'.format(scheme))
        matches = re.match(
            r'(?P<domain>[\w|\.]+)?(?P<port>:\d{2,5})?(?P<path>[\w|/]*)?',
            url_string)
        if matches is None:
            raise Exception(
                'the argument seems not to be a url string, {}'.format(value))

        # domain must be resolved.
        domain = matches.group('domain')
        if domain is None:
            raise Exception(
                'url contains no domain, {}'.format(value))
        try:
            # https://github.com/python/cpython/blob/master/Modules/socketmodule.c#L5729
            ipaddress = socket.gethostbyname(domain)
        except OSError as error:  # resolve failed
            raise Exception('unresolved domain, {} {}'.format(
                domain, error)) from error
        else:
            LOG.debug('%s resolved %s', domain, ipaddress)

        # path(optional)
        if matches.group('path') is None:
            raise Exception(
                'url contains no path, {}'.format(value))
        path = matches.group('path')
        # port(optional)
        port = matches.group('port')
        LOG.debug('url=%s domain=%s port=%s path=%s', value, domain, port, path)
        if getattr(self, '_url', None) is None:
            self._url = value

    def headers(self, val):
        """Sets the url."""
        if getattr(self, '_hdrs', None) is None:
            self._hdrs = val

    def _HTTP_REQUEST_METHOD(self, r3api, req):   # pylint: disable=invalid-name
        agent_error = _AgentError.NONE
        try:
            ctx = None
            if req.type == 'https':
                # https://docs.python.jp/3/library/ssl.html#ssl.create_default_context
                ctx = ssl.create_default_context()
                if self._allow_self_signed_cert:
                    # https://github.com/python/cpython/blob/master/Lib/ssl.py#L567
                    ctx.check_hostname = False
                    ctx.verify_mode = ssl.CERT_NONE
            with urllib.request.urlopen(req, timeout=self._timeout_seconds, context=ctx) as res:
                r3api.response(res.getcode(), res.geturl(), res.info(), res.read().decode('utf-8'))
                return True
        except HTTPError as error:
            LOG.error(
                'Could not complete the request. code %s reason %s headers %s',
                error.code, error.reason, error.headers)
            agent_error = _AgentError.FATAL
        except (ContentTooShortError, URLError) as error:
            # https://github.com/python/cpython/blob/master/Lib/urllib/error.py#L73
            LOG.error('Could not read the server. reason %s', error.reason)
            agent_error = _AgentError.FATAL
        except (socket.timeout, OSError) as error:  # temporary error
            LOG.error('error(OSError, socket) %s', error)
            agent_error = _AgentError.TEMP
        finally:
            if agent_error == _AgentError.TEMP:
                self._retries -= 1  # decrement the retries value.
                if self._retries >= 0:
                    LOG.warning('sleeping for %s. remaining retries=%s',
                                self._retry_interval_seconds,
                                self._retries)
                    time.sleep(self._retry_interval_seconds)
                    self.GET(r3api)
                else:
                    LOG.error("reached the max retry count.")
                    agent_error = _AgentError.FATAL

        if agent_error == _AgentError.NONE:
            LOG.debug('no problem.')
            return True
        LOG.debug('problem. See the error log.')
        return False

    def POST(self, r3api):  # pylint: disable=invalid-name
        """Sends requests by using POST Method."""
        # 1. Constructs request url using K2hr3Api.path property.
        url = "/".join([self._url, r3api.path])

        # 2. Constructs url parameters using K2hr3Api.params property.
        # 4.1. Checks content-type
        content_type = r3api.headers.get('Content-Type')
        if content_type == "application/json":
            query = r3api.body
            query = query.encode('ascii')
        else:
            query = urllib.parse.urlencode(r3api.params)
            query = query.encode('ascii')

        # 3. Constructs headers using K2hr3Api.headers property.
        self._hdrs.update(r3api.headers)

        # 4. Sends a request.
        req = urllib.request.Request(url, data=query, headers=self._hdrs, method="POST")
        if req.type not in ('http', 'https'):
            LOG.error('http or https, not {}'.format(req.type))
            return False
        return self._HTTP_REQUEST_METHOD(r3api, req)

    def PUT(self, r3api):  # pylint: disable=invalid-name
        """Sends requests by using PUT Method."""
        # 1. Constructs request url using K2hr3Api.path property.
        url = "/".join([self._url, r3api.path])

        # 2. Constructs url parameters using K2hr3Api.params property.
        # query = urllib.parse.urlencode(r3api.params, quote_via=urllib.parse.quote)
        query = urllib.parse.urlencode(r3api.params)
        url = "?".join([url, query])

        # 3. Constructs headers using K2hr3Api.headers property.
        self._hdrs.update(r3api.headers)

        # 4. Sends a request.
        req = urllib.request.Request(url, data=None, headers=self._hdrs, method="PUT")
        if req.type not in ('http', 'https'):
            LOG.error('http or https, not {}'.format(req.type))
            return False
        return self._HTTP_REQUEST_METHOD(r3api, req)

    def GET(self, r3api):   # pylint: disable=invalid-name
        """Sends requests by using GET Method."""
        # 1. Constructs request url using K2hr3Api.path property.
        url = "/".join([self._url, r3api.path])

        # 2. Constructs url parameters using K2hr3Api.params property.
        # query = urllib.parse.urlencode(r3api.params, quote_via=urllib.parse.quote)
        query = urllib.parse.urlencode(r3api.params)
        url = "?".join([url, query])

        # 3. Constructs headers using K2hr3Api.headers property.
        self._hdrs.update(r3api.headers)

        # 4. Sends a request.
        req = urllib.request.Request(url, headers=self._hdrs, method="GET")
        if req.type not in ('http', 'https'):
            LOG.error('http or https, not {}'.format(req.type))
            return False
        return self._HTTP_REQUEST_METHOD(r3api, req)

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
