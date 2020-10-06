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

#
# A simple script to create a k2hr3-dkc server on localhost
#

# Sets the default locale. LC_ALL has precedence over other LC* variables.
unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# Sets PATH. setup_*.sh uses useradd command
PATH=${PATH}:/bin:/usr/bin:/usr/sbin:/sbin

# an unset parameter expansion will fail
set -u

# umask 022 is enough
umask 022

# defines environments
SRCDIR=$(cd $(dirname "$0") && pwd)

function k2hdkc_patch_file {
    ORIGINAL_FILE=$1
    PATCH_FILE=$2
    if test -f "${ORIGINAL_FILE}"; then
        if test -f "${PATCH_FILE}" ; then
            echo "patch for ${ORIGINAL_FILE}"
            patch ${ORIGINAL_FILE} < ${PATCH_FILE}
        else
            echo "NO ${PATCH_FILE}"
            exit 1
        fi
    else
        echo "NO ${ORIGINAL_FILE}"
        exit 1
    fi
}

if test -f "/etc/os-release"; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=$VERSION_ID
else
    echo "unknown OS, no /etc/os-release and /etc/centos-release"
    exit 1
fi

if test -z "${OS_NAME}" -o -z "${OS_VERSION}"; then
    echo "unknown OS, neither /etc/os-release nor /etc/centos-release"
    exit 1
fi
echo "${OS_NAME} ${OS_VERSION}"

# 1. sets the package repository root
SITE_PACKAGES_ROOT=/opt/guest-agent-venv/lib64/python3.6/site-packages

# 2. applies patches
which patch
if test "${?}" != 0; then
    echo "patch not found"
    if test "${OS_NAME}" = "centos" -a "${OS_VERSION}" = "8"; then
        echo "sudo dnf install -y patch"
        sudo dnf install -y patch
        if test "${?}" != 0; then
            echo "patch install failed"
            exit 1
        fi
    else
        echo "Currently ${OS_NAME} && ${OS_VERSION} not supported"
        exit 1
    fi
else
    echo "patch command found"
fi
# 2.1. trove/common/cfg.py
k2hdkc_patch_file ${SITE_PACKAGES_ROOT}/trove/common/cfg.py ${SRCDIR}/patches/trove-common-cfg.py

# 2.2. trove/guestagent/datastore/experimental/k2hdkc
if ! test -d "${SITE_PACKAGES_ROOT}/trove/guestagent/datastore/experimental"; then
    sudo mkdir -p ${SITE_PACKAGES_ROOT}/trove/guestagent/datastore/experimental
fi

echo "installing ${SITE_PACKAGES_ROOT}/trove/guestagent/datastore/experimental"
sudo cp -r ${SRCDIR}/guestagent/datastore/experimental/k2hdkc ${SITE_PACKAGES_ROOT}/trove/guestagent/datastore/experimental

# 2.3. trove/guestagent/dbaas.py
k2hdkc_patch_file ${SITE_PACKAGES_ROOT}/trove/guestagent/dbaas.py ${SRCDIR}/patches/trove-guestagent-dbaas.py

# 2.4. trove/common/configurations.py
k2hdkc_patch_file ${SITE_PACKAGES_ROOT}/trove/common/configurations.py ${SRCDIR}/patches/trove-common-configurations.py

# 2.5. trove/common/template.py
k2hdkc_patch_file ${SITE_PACKAGES_ROOT}/trove/common/template.py ${SRCDIR}/patches/trove-common-template.py

# 2.6. trove/guestagent/strategies/backup/experimental/k2hdkc_impl.py
if ! test -d "${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/backup/experimental"; then
    sudo mkdir -p ${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/backup/experimental
fi

for file in $(find ${SRCDIR}/guestagent/strategies/backup/experimental -maxdepth 1 -type f); do
    echo "cp ${file} ${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/backup/experimental"
    cp ${file} ${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/backup/experimental
done


# 2.7. trove/guestagent/strategies/restore/experimental/k2hdkc_impl.py
if ! test -d "${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/restore/experimental"; then
    sudo mkdir -p ${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/restore/experimental
fi

for file in $(find ${SRCDIR}/guestagent/strategies/restore/experimental -maxdepth 1 -type f); do
    echo "cp ${file} ${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/restore/experimental"
    cp ${file} ${SITE_PACKAGES_ROOT}/trove/guestagent/strategies/restore/experimental
done

# 2.8. usr/libexec/k2hdkc-snapshot
if test -f "${SRCDIR}/usr/libexec/k2hdkc-snapshot"; then
    echo "sudo install -C -m 0755 -o root -v ${SRCDIR}/usr/libexec/k2hdkc-snapshot /usr/libexec/k2hdkc-snapshot"
    sudo install -C -m 0755 -o root -v ${SRCDIR}/usr/libexec/k2hdkc-snapshot /usr/libexec/k2hdkc-snapshot
    RESULT=$?
    if test "${RESULT}" -ne 0; then
        echo "RESULT should be zero, not ${RESULT}"
        exit 1
    fi
else
    echo "${SRCDIR}/usr/libexec/k2hdkc-snapshot should exist"
    exit 1
fi

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
