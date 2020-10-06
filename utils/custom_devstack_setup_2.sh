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
# A script to create a devstack environment.
# NOTE:
#     This script fixes OpenStack version to Ussuri.

# Sets the default locale. LC_ALL has precedence over other LC* variables.
unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# Sets PATH. setup_*.sh uses useradd command
PATH=${PATH}:/usr/sbin:/sbin

# local variables
SRCDIR=$(cd $(dirname "$0") && pwd)
DEVSTACK_DIR=/opt/stack/devstack
DEVSTACK_BRANCH=stable/ussuri

# an unset parameter expansion will fail
set -u

# umask 022 is enough
umask 022

if test -f "/etc/os-release"; then
    . /etc/os-release
    OS_NAME=$ID
else
    echo "[NO] unknown OS, no /etc/os-release"
    exit 1
fi
if test "${USER}" != "stack"; then
    echo "[NO] USER must be stack: USER=${USER}"
    exit 1
fi
if test -d "${DEVSTACK_DIR}"; then
    echo "[NO] ${DEVSTACK_DIR} already existed"
    exit 1
fi

if test "${OS_NAME}" = "centos"; then
    sudo dnf -y update
    sudo dnf install -y git
    git clone https://git.openstack.org/openstack-dev/devstack --branch ${DEVSTACK_BRANCH}

    # Uses the custom git repository
    sh ${SRCDIR}/custom_devstack_local.conf.sh

    # Calls internal functions if exist
    if test -x "${SRCDIR}/custom_internal_devstack_setup_2.sh"; then
        /bin/sh ${SRCDIR}/custom_internal_devstack_setup_2.sh
    fi

    # RDO release for Ussuri
    sudo dnf install -y https://repos.fedorapeople.org/repos/openstack/openstack-ussuri/rdo-release-ussuri-1.el8.noarch.rpm

    # PyYAML
    sudo dnf install -y python3-pip
    sudo -H pip3 install --ignore-installed PyYAML

    # Yum utils
    sudo dnf -y install yum-utils

    # https://www.mail-archive.com/devel@ovirt.org/msg15564.html
    sudo dnf install -y libibverbs.so.1 libmlx5

    # semanage is required
    sudo dnf install -y policycoreutils-python-utils

    # Deactivates libvirt default network eternally
    sudo virsh net-destroy default
    sudo virsh net-autostart --network default --disable

    cd ${DEVSTACK_DIR}
    STACK_USER=$(whoami)
    ./stack.sh

    echo "sudo systemctl restart httpd"
    sudo systemctl restart httpd

    echo "sudo systemctl start memcached"
    sudo systemctl start memcached
else
    echo "[NO] centos only currently supported, not ${OS_NAME}"
    exit 1
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
