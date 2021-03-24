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

from k2hr3client.policy import K2hr3Policy

LOG = logging.getLogger(__name__)


class TestK2hr3Policy(unittest.TestCase):
    """Tests the K2hr3Policy class.

    Simple usage(this class only):
    $ python -m unittest tests/test_resource.py

    Simple usage(all):
    $ python -m unittest tests
    """
    def setUp(self):
        """Sets up a test case."""
        RESOURCE_PATH = "yrn:yahoo:::demo:resource:my_resource"
        self.token = "r3tokenvalue"
        self.name = "testpolicy"
        self.effect = 'allow'
        self.action = ['yrn:yahoo::::action:read']
        self.resource = [RESOURCE_PATH]
        self.condition = None
        self.alias = []

    def tearDown(self):
        """Tears down a test case."""

    def test_k2hr3resource_construct(self):
        """Creates a K2hr3Policy  instance."""
        k2hr3_policy = K2hr3Policy(self.token,
                                   name=self.name,
                                   effect=self.effect,
                                   action=self.action,
                                   resource=self.resource,
                                   condition=self.condition,
                                   alias=self.alias)
        self.assertIsInstance(k2hr3_policy, K2hr3Policy)

    def test_k2hr3resource_repr(self):
        """Represent a K2hr3Policy instance."""
        k2hr3_policy = K2hr3Policy(self.token,
                                   name=self.name,
                                   effect=self.effect,
                                   action=self.action,
                                   resource=self.resource,
                                   condition=self.condition,
                                   alias=self.alias)
        self.assertRegex(repr(k2hr3_policy), '<K2hr3Policy .*>')


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
