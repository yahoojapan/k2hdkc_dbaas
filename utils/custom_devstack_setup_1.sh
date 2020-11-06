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

#
# Checks if nested virtualization is enabled
#
probe_kvm_intel_nested() {
    if test -f "/sys/module/kvm_intel/parameters/nested"; then
        IS_YN=$(cat /sys/module/kvm_intel/parameters/nested)
        if test "${IS_YN}" = "Y" -o "${IS_YN}" = "1" ; then
            echo "[OK] kvm_intel nested is 1 or Y:${IS_YN}"
            return 0
        else 
            echo "[NO] kvm_intel nested is not 1 nor Y:${IS_YN}"
        fi
    else
        echo "[NO] /sys/module/kvm_intel/parameters/nested doesn't exist"
    fi
    echo "[NO] kvm_intel nested is currently not supported"
    return 1
}

#
# Adds nested=1 to kvm_intel module if nested = 0
#
probe_kvm_intel () {

    probe_kvm_intel_nested
    if test "${?}" -eq 1; then
        echo "[NO] Try to reload the module because kvm_intel nested is currently not supported."
    else
        echo "[OK] kvm_intel nested is already supported."
        return 0
    fi

    # Adds 'options kvm_intel nested=y' to dist.conf to enable it permanently.
    # See https://docs.openstack.org/devstack/latest/guides/devstack-with-nested-kvm.html
    grep "options kvm_intel nested=y" /etc/modprobe.d/dist.conf >/dev/null 2>&1
    if test "${?}" -ne 0; then
        echo 'options kvm_intel nested=y' | sudo tee -a /etc/modprobe.d/dist.conf
    else
        echo 'options kvm_intel nested=y already exists in /etc/modprobe.d/dist.conf'
    fi

    # try to re-load the module
    sudo modprobe -r kvm_intel
    sudo modprobe -a kvm_intel 1>/dev/null 2>&1 
    if test "$?" != "0"; then
        echo "[NO] kvm_intel module is not supported"
        return 1
    fi
    lsmod | grep kvm_intel
    if test "$?" != "0"; then
        echo "[NO] kvm_intel module not found"
        return 1
    fi

    # Checks if nested is featured
    probe_kvm_intel_nested
    if test "${?}" -eq 1; then
        echo "[NO] kvm_intel nested is not supported"
        return 1
    fi
    echo "[OK] kvm_intel nested is currently supported"
    return 0
}

probe_kvm_amd() {
    lscpu | grep -E "^Vendor ID:(\s+)AuthenticAMD$" >/dev/null 2>&1
    if test "$?" = "0"; then
        lscpu | grep -E "^Hypervisor vendor:(\s+)KVM$" >/dev/null 2>&1
        if test "$?" = "0"; then
            lscpu | grep -E "^Virtualization type:(\s+)full$" >/dev/null 2>&1
            if test "$?" = "0"; then
                echo "[OK] Full virtualization supported"
                return 0
            fi
        fi
    fi
    return 1
}

probe_kvm_azure() {
    echo "lscpu | grep -E '^Hypervisor vendor:(\s+)Microsoft$'" >/dev/null 2>&1
    lscpu | grep -E "^Hypervisor vendor:(\s+)Microsoft$" >/dev/null 2>&1
    if test "$?" = "0"; then
        echo "[OK] Full virtualization supported"
        return 0
    fi
    return 1
}

probe_nested_virtualization_enabled() {
    probe_kvm_intel
    if test "$?" -eq 0; then
        echo "[OK] kvm_intel supports nested virtualization"
        return 0
    fi
    probe_kvm_amd
    if test "$?" -eq 0; then
        echo "[OK] kvm supports nested virtualization"
        return 0
    fi
    probe_kvm_azure
    if test "$?" -eq 0; then
        echo "[OK] kvm supports nested virtualization"
        return 0
    fi
    return 1
}

if test "${OS_NAME}" = "centos"; then
    # Enables Nested Virtualization of some kernel module
    probe_nested_virtualization_enabled
    if test "${?}" -eq 0; then
        echo "[OK] nested virtualization is enabled"
    else
        echo "[NO] nested virtualization is not enabled"
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

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
