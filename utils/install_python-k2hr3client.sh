#!/bin/sh
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

# Sets the default locale. LC_ALL has precedence over other LC* variables.
unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# Sets PATH. setup_*.sh uses useradd command
PATH=${PATH}:/usr/sbin:/sbin

# an unset parameter expansion will fail
set -u

# umask 022 is enough
umask 022

if test "${USER}" != "stack"; then
    echo "[NO] USER must be stack: USER=${USER}"
    exit 1
fi

which python3
if test "$?" != "0"; then
    echo "[NO] no python3. Please install python3 package"
    exit 1
fi
which pip
if test "$?" != "0"; then
    echo "[NO] no pip. Please install pip package"
    exit 1
fi

# defines environments
SRCDIR=$(cd $(dirname "$0") && pwd)
PKGDIR=${SRCDIR}/python-k2hr3client/
if ! test -d "${PKGDIR}"; then
    echo "[NO] no ${PKGDIR}. Please check the dir where python-k2hr3client exists"
    exit 1
fi
CLIENT_VERSION=$(cat ${PKGDIR}/HISTORY.rst | perl -lne 'print $1 if /^([0-9]+.[0-9]+.[0-9]+) \([0-9]{4}-[0-9]{2}-[0-9]{2}\)$/')

cd ${PKGDIR}
python3 setup.py sdist
if test "$?" != "0"; then
    echo "[NO] python3 setup.py sdist should return zero"
    exit 1
fi
sudo pip install dist/python-k2hr3client-${CLIENT_VERSION}.tar.gz 
if test "$?" != "0"; then
    echo "[NO] sudo pip install dist/python-k2hr3client-${CLIENT_VERSION}.tar.gz should return zero"
    exit 1
fi

echo "[OK] sudo pip install dist/python-k2hr3client-${CLIENT_VERSION}.tar.gz"
exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
