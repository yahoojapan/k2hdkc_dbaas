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
"""Test Package for K2hr3 Python Client.

This file is needed to run tests simply like:
$ python -m unittest discover

All of the test files must be a package importable from the top-level directory of the project.
https://docs.python.org/3.6/library/unittest.html#test-discovery
"""
from __future__ import (absolute_import, division, print_function,
                        unicode_literals)
__author__ = 'Hirotaka Wakabayashi <hiwakaba@yahoo-corp.jp>'
__version__ = '0.0.1'

# Disables the k2hr3client library logs by failure assetion tests.
import logging
logging.getLogger('k2hr3client').addHandler(logging.NullHandler())

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
