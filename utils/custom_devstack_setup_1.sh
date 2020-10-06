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
# A simple script to setup the devstack runtime environment.

# Sets the default locale. LC_ALL has precedence over other LC* variables.
unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# Sets PATH. setup_*.sh uses useradd command
PATH=${PATH}:/usr/sbin:/sbin

# local variables
SRCDIR=$(cd $(dirname "$0") && pwd)

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

if test "${OS_NAME}" = "centos"; then
    lsmod | grep kvm_intel
    if test "$?" != "0"; then
        echo "[NO] kvm_intel module not found"
        exit 1
    else
        echo "DEBUG grep kvm_intel"
    fi

    echo "sudo rmmod kvm_intel"
    sudo rmmod kvm_intel
    echo 'options kvm_intel nested=y' | sudo tee /etc/modprobe.d/dist.conf
    echo "sudo modprobe kvm_intel"
    sudo modprobe kvm_intel
    echo "sudo lsmod | grep kvm_intel"

    if test -f "/sys/module/kvm_intel/parameters/nested"; then
        IS_YN=$(cat /sys/module/kvm_intel/parameters/nested)
        if test "${IS_YN}" != "Y" -a "${IS_YN}" != "1" ; then
            echo "[NO] nested should be Y. IS_YN is ${IS_YN}"
            exit 1
        fi
    else
        echo '[NO] no /sys/module/kvm_intel/parameters/nested exists'
        exit 1
    fi

    echo "sudo dnf install -y python36-devel"
    sudo dnf install -y python36-devel

    echo "sudo useradd -s /bin/bash -d /opt/stack -m stack"
    sudo useradd -s /bin/bash -d /opt/stack -m stack
    echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    echo "sudo chmod 755 /opt/stack"
    sudo chmod 755 /opt/stack

else
    echo "[NO] centos only currently supported, not ${OS_NAME}"
    exit 1
fi

# Calls internal functions if exist
if test -x "${SRCDIR}/custom_internal_devstack_setup_1.sh"; then
    /bin/sh ${SRCDIR}/custom_internal_devstack_setup_1.sh
fi

echo "reboot"
sudo reboot

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
