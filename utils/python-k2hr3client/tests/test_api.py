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
"""Test Package for K2hr3 Python Client."""
from __future__ import (absolute_import, division, print_function,
                        unicode_literals)

import logging
import unittest

from k2hr3client.api import _K2hr3ApiResponse

LOG = logging.getLogger(__name__)


class TestK2hr3ApiResponse(unittest.TestCase):
    """Tests the K2hr3ApiResponse class.

    Simple usage(this class only):
    $ python -m unittest tests/test_r3token.py

    Simple usage(all):
    $ python -m unittest tests
    """
    def setUp(self):
        """Sets up a test case."""

    def tearDown(self):
        """Tears down a test case."""

    def test_k2hr3apiresponse_construct(self):
        """Creates a K2hr3ApiResponse instance."""
        response = _K2hr3ApiResponse()
        self.assertIsInstance(response, _K2hr3ApiResponse)

    def test_k2hr3apiresponse_repr(self):
        """Represent a K2hr3ApiResponse instance."""
        response = _K2hr3ApiResponse()
        # Note: The order of _error and _code is unknown!
        self.assertRegex(repr(response), '<_K2hr3ApiResponse .*>')


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
