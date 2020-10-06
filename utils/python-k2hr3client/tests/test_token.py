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

from k2hr3client.token import K2hr3Token, K2hr3RoleToken, K2hr3RoleTokenList

LOG = logging.getLogger(__name__)


class TestK2hr3token(unittest.TestCase):
    """Tests the K2hr3token class.

    Simple usage(this class only):
    $ python -m unittest tests/test_token.py

    Simple usage(all):
    $ python -m unittest tests
    """
    def setUp(self):
        """Sets up a test case."""
        self.project = "my_project"
        self.token = "my_iaas_token"
        self.r3token = "my_r3_token"
        self.role = "my_role"
        self.expire = 0
        self.expand = True

    def tearDown(self):
        """Tears down a test case."""

    def test_k2hr3token_construct(self):
        """Creates a K2hr3Token instance."""
        token = K2hr3Token(self.project, self.token)
        self.assertIsInstance(token, K2hr3Token)

    def test_k2hr3token_repr(self):
        """Represent a K2hr3Token instance."""
        token = K2hr3Token(self.project, self.token)
        # Note: The order of _error and _code is unknown!
        self.assertRegex(repr(token), '<K2hr3Token .*>')

    def test_k2hr3roletoken_construct(self):
        """Creates a K2hr3RoleToken instance."""
        token = K2hr3RoleToken(self.r3token, self.role, self.expire)
        self.assertIsInstance(token, K2hr3RoleToken)

    def test_k2hr3roletoken_repr(self):
        """Represent a K2hr3RoleToken instance."""
        token = K2hr3RoleToken(self.r3token, self.role, self.expire)
        # Note: The order of _error and _code is unknown!
        self.assertRegex(repr(token), '<K2hr3RoleToken .*>')

    def test_k2hr3roletokenlist_construct(self):
        """Creates a K2hr3RoleTokenList instance."""
        token = K2hr3RoleTokenList(self.r3token, self.role, self.expand)
        self.assertIsInstance(token, K2hr3RoleTokenList)

    def test_k2hr3roletokenlist_repr(self):
        """Represent a K2hr3RoleTokenlist instance."""
        token = K2hr3RoleTokenList(self.r3token, self.role, self.expand)
        # Note: The order of _error and _code is unknown!
        self.assertRegex(repr(token), '<K2hr3RoleTokenList .*>')


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
