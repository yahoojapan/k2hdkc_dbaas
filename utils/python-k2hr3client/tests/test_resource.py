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

from k2hr3client.resource import K2hr3Resource

LOG = logging.getLogger(__name__)


class TestK2hr3Resource(unittest.TestCase):
    """Tests the K2hr3Resource class.

    Simple usage(this class only):
    $ python -m unittest tests/test_resource.py

    Simple usage(all):
    $ python -m unittest tests
    """
    def setUp(self):
        """Sets up a test case."""
        self.name = "test_resource"
        self.data_type = 'string'
        self.data = "testresourcedata"
        self.keys = {
            "cluster-name": "testcluster",
            "chmpx-server-port": "8020",
            "chmpx-server-ctrlport": "8021",
            "chmpx-slave-ctrlport": "8031"
        }
        self.alias = []

    def tearDown(self):
        """Tears down a test case."""

    def test_k2hr3resource_construct(self):
        """Creates a K2hr3Resoiurce  instance."""
        resource = K2hr3Resource("k2hr3tokenvalue", self.name, self.data_type,
                                 self.data, self.keys, self.alias)
        self.assertIsInstance(resource, K2hr3Resource)

    def test_k2hr3resource_repr(self):
        """Represent a K2hr3Resource instance."""
        resource = K2hr3Resource("k2hr3tokenvalue", self.name, self.data_type,
                                 self.data, self.keys, self.alias)
        # Note: The order of _error and _code is unknown!
        self.assertRegex(repr(resource), '<K2hr3Resource .*>')


#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
