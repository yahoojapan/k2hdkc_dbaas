#!/bin/sh
#
# K2HR3 PACK for K2HDKC DBaaS based on Trove
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
# AUTHOR:   Takeshi Nakatani
# CREATE:   Mon Sep 14 2020
# REVISION:
#

#
# [NOTE]
# We need to set an arbitrary umask when running npm with sudo.
# However, it is assumed that umask cannot be specified due to system sudoers.
# So instead of running npm directly with sudo, run it via this script.
# This script sets the umask before running npm.
#
if [ $# -ne 1 ]; then
	exit 1
fi

BASE_DIR=$1
if [ ! -d ${BASE_DIR} ]; then
	exit 1
fi
cd ${BASE_DIR} >/dev/null 2>&1

OLD_UMASK=`umask`
umask 0000

npm run start
if [ $? -ne 0 ]; then
	exit $?
fi

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
