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
# A simple script to create a k2hdkc qcow2 diskimage on devstack
#
# ex)
# $ ./disk-image-create.sh
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

print_usage() {
    echo "usage : $(basename $0) [-n database] [-h]"
    echo "  -n <DATABASE>      database name"
    echo "  -o <OSNAME>        OSNAME"
    echo "  -r <OSRELEASE>     OSRELEASE"
    echo "  -h                 print usage"
    echo ""
    exit 1
}

MY_DB=k2hdkc
while true; do
    case "${1-}" in
        -n) shift; MY_DB="${1}";;
        -o) shift; DISTRO_NAME="${1}";;
        -r) shift; DIB_RELEASE="${1}";;
        -h) print_usage;;
        *) break;;
    esac
    shift
done

# defines environments
BRANCH_OVERRIDE=stable/ussuri
SRCDIR=/opt/stack
MY_HOST_IP=$(ip route get 8.8.8.8 | head -1 | awk '{print $7}')
MY_DIB_ELEMENTS_PATH=${SRCDIR}/k2hdkc_dbaas/dib/elements
ELEMENTS_PATH=${SRCDIR}/trove/integration/scripts/files/elements
ELEMENTS_PATH=${ELEMENTS_PATH}:${MY_DIB_ELEMENTS_PATH}
DIB_RELEASE=${DIB_RELEASE:-8}
DIB_PYTHON_VERSION=3
DIB_PYTHON=python3
DISTRO_NAME=${DISTRO_NAME:-centos}
GUEST_LOGDIR=${GUEST_LOGDIR:-"/var/log/trove/"}
HOST_SCP_USERNAME=${HOST_SCP_USERNAME:-$(whoami)}
PATH_TROVE=${PATH_TROVE:-${SRCDIR}/trove}
SSH_DIR=${SSH_DIR:-"${SRCDIR}/ssh"}
if [ -d ${SSH_DIR} ]; then
    echo "${SSH_DIR} already exists"
else
    echo "Creating ${SSH_DIR} for ${HOST_SCP_USERNAME}"
    sudo -Hiu ${HOST_SCP_USERNAME} mkdir -m go-w -p ${SSH_DIR}
fi
if [ ! -f ${SSH_DIR}/id_rsa.pub ]; then
    /usr/bin/ssh-keygen -f ${SSH_DIR}/id_rsa -q -N ""
fi
cat ${SSH_DIR}/id_rsa.pub >> ${SSH_DIR}/authorized_keys
sort ${SSH_DIR}/authorized_keys | uniq > ${SSH_DIR}/authorized_keys.uniq
mv ${SSH_DIR}/authorized_keys.uniq ${SSH_DIR}/authorized_keys
chmod 600 ${SSH_DIR}/authorized_keys
export CONTROLLER_IP=${CONTROLLER_IP:-${MY_HOST_IP}}
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
export DIB_PYTHON=python3
export DIB_PYTHON_VERSION
export DIB_IMAGE_SIZE=2G
export DIB_INIT_SYSTEM=systemd
export DISTRO_NAME=${DISTRO_NAME}
export DIB_RELEASE=${DIB_RELEASE}
export ELEMENTS_PATH=${ELEMENTS_PATH}:${MY_DIB_ELEMENTS_PATH}
export ESCAPED_GUEST_LOGDIR=$(echo ${GUEST_LOGDIR} | sed 's/\//\\\//g')
export ESCAPED_PATH_TROVE=$(echo ${PATH_TROVE} | sed 's/\//\\\//g')
export GUEST_LOGDIR=${GUEST_LOGDIR:-"/var/log/trove/"}
export GUEST_USERNAME=${GUEST_USERNAME:-centos}
export HOST_SCP_USERNAME=${HOST_SCP_USERNAME:-$(whoami)}
export HOST_USERNAME=${HOST_SCP_USERNAME}
export PATH_TROVE=${PATH_TROVE:-${SRCDIR}/trove}
export SSH_DIR=${SSH_DIR}
export TROVESTACK_SCRIPTS=${TROVESTACK_SCRIPTS:-$PATH_TROVE/integration/scripts}

ELEMENTS="base vm pip-and-virtualenv pip-cache"
if [ "${DISTRO_NAME}" = "centos" ]; then
    ELEMENTS="${ELEMENTS} centos-8-guest guest-agent-${MY_DB} centos centos-8-${MY_DB}"
else
    ELEMENTS="${ELEMENTS} ubuntu-guest-stable-ussuri guest-agent-${MY_DB} ubuntu ubuntu-${MY_DB} no-resolvconf"
fi

# install k2hr3_utils scripts
install -CD -m 0444 -v ${SRCDIR}/k2hr3_utils/devcluster/cluster_functions ${MY_DIB_ELEMENTS_PATH}/centos-8-${MY_DB}/install.d/cluster_functions
install -CD -m 0755 -v ${SRCDIR}/k2hr3_utils/devcluster/cluster.sh ${MY_DIB_ELEMENTS_PATH}/centos-8-${MY_DB}/install.d/cluster.sh
install -CD -m 0444 -v ${SRCDIR}/k2hr3_utils/devcluster/chmpx/setup_chmpx_functions ${MY_DIB_ELEMENTS_PATH}/centos-8-${MY_DB}/install.d/chmpx/setup_chmpx_functions
install -CD -m 0755 -v ${SRCDIR}/k2hr3_utils/devcluster/dkc/setup_dkc.sh ${MY_DIB_ELEMENTS_PATH}/centos-8-${MY_DB}/install.d/dkc/setup_dkc.sh

disk-image-create -x -a amd64 -o ${SRCDIR}/images/trove-datastore-${DISTRO_NAME}-${DIB_RELEASE}-${MY_DB} -t qcow2 \
    --image-size 6 \
    --image-cache ~/.cache/image-create \
    --logfile build.log \
    --no-tmpfs ${ELEMENTS}
exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
