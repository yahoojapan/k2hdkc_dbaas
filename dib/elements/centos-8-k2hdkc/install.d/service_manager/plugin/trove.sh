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
# A simple script to create a k2hr3-dkc server on localhost
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

# defines environments

function setup_service_manager {
logger -t ${TAG} -p user.info "trove.sh configure_systemd"

########
# 8. Configures the chmpx's service manager default configuration
# We recommend chmpx process works as a service by systemd.
#
logger -t ${TAG} -p user.info "8. Configures the chmpx's service manager default configuration"

# Determines the service management file which file format depends on a service manager of the target OS
if test "${SERVICE_MANAGER}" = "systemd"; then
service_manager_file=${SRCDIR}/../service_manager/chmpx-trovectl.service
else
logger -t ${TAG} -p user.err "SERVICE_MANAGER must be either systemd, not ${SERVICE_MANAGER}"
return 1
fi
# Configures the chmpx's service manager default configuration
is_k2hdkc=0
configure_chmpx_service_manager_file ${SERVICE_MANAGER} ${service_manager_file} ${k2hr3_dkc_runuser} ${chmpx_conf_file} ${chmpx_msg_max} ${is_k2hdkc} ${chmpx_loglevel}
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "configure_chmpx_service_manager_file should return zero, not ${RET}"
return 1
fi

########
# 9. Installs the chmpx service manager configuration and enables it
# systemd controls chmpx.
#
logger -t ${TAG} -p user.info "9. Installs the chmpx service manager configuration and enables it"

if test -f "${SRCDIR}/../service_manager/scripts/k2hdkc-trovectl"; then
logger -t ${TAG} -p user.debug "sudo install -C -m 0755 -o root -v ${SRCDIR}/../service_manager/scripts/k2hdkc-trovectl /usr/libexec/k2hdkc-trovectl"
sudo install -C -m 0755 -o root -v ${SRCDIR}/../service_manager/scripts/k2hdkc-trovectl /usr/libexec/k2hdkc-trovectl
RESULT=$?
if test "${RESULT}" -ne 0; then
    logger -t ${TAG} -p user.err "RESULT should be zero, not ${RESULT}"
    return 1
fi
else
logger -t ${TAG} -p user.err "${SRCDIR}/../service_manager/scripts/k2hdkc-trovectl should exist"
return 1
fi

install_service_manager_conf ${SERVICE_MANAGER} chmpx-trovectl
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "install_service_manager_conf should return zero, not ${RET}"
return 1
fi

########
# 10. Configures the k2hdkc's service manager default configuration
# We recommend k2hdkc processes work as a service by systemd.
#
logger -t ${TAG} -p user.info "10. Configures the k2hdkc's service manager default configuration"

# Determines the service management file which file format depends on a service manager of the target OS
if test "${SERVICE_MANAGER}" = "systemd"; then
service_manager_file=${SRCDIR}/../service_manager/k2hdkc-trove.service
else
logger -t ${TAG} -p user.err "SERVICE_MANAGER must be either systemd, not ${SERVICE_MANAGER}"
return 1
fi
# Configures the k2hdkc's service manager default configuration
is_k2hdkc=1
configure_chmpx_service_manager_file ${SERVICE_MANAGER} ${service_manager_file} ${k2hr3_dkc_runuser} ${chmpx_conf_file} ${chmpx_msg_max} ${is_k2hdkc} ${k2hdkc_loglevel}
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "configure_chmpx_service_manager_file should return zero, not ${RET}"
return 1
fi

########
# 11. Installs the k2hdkc service manager configuration and enables it
# systemd controls k2hdkc
#
logger -t ${TAG} -p user.info "11. Installs the k2hdkc service manager configuration and enables it"

if test -f "${SRCDIR}/../service_manager/scripts/k2hdkc-trove-helper"; then
logger -t ${TAG} -p user.debug "sudo install -C -m 0755 -o root -v ${SRCDIR}/../service_manager/scripts/k2hdkc-trove-helper /usr/libexec/k2hdkc-trove-helper"
sudo install -C -m 0755 -o root -v ${SRCDIR}/../service_manager/scripts/k2hdkc-trove-helper /usr/libexec/k2hdkc-trove-helper
RESULT=$?
if test "${RESULT}" -ne 0; then
    logger -t ${TAG} -p user.err "RESULT should be zero, not ${RESULT}"
    return 1
fi
else
logger -t ${TAG} -p user.err "${SRCDIR}/../service_manager/scripts/k2hdkc-trove-helper should exist"
return 1
fi

install_service_manager_conf ${SERVICE_MANAGER} k2hdkc-trove
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "install_service_manager_conf should return zero, not ${RET}"
return 1
fi

########
# 12. Configures the k2hdkc-trovectl's service manager default configuration
# We recommend k2hdkc-trovectl processes work as a service by systemd.
#
logger -t ${TAG} -p user.info "12. Configures the k2hdkc-trovectl's service manager default configuration"

# Determines the service management file which file format depends on a service manager of the target OS
if test "${SERVICE_MANAGER}" = "systemd"; then
service_manager_file=${SRCDIR}/../service_manager/k2hdkc-trovectl.service
else
logger -t ${TAG} -p user.err "SERVICE_MANAGER must be either systemd, not ${SERVICE_MANAGER}"
return 1
fi
# Configures the k2hdkc's service manager default configuration
is_k2hdkc=1
configure_chmpx_service_manager_file ${SERVICE_MANAGER} ${service_manager_file} ${k2hr3_dkc_runuser} ${chmpx_conf_file} ${chmpx_msg_max} ${is_k2hdkc} ${k2hdkc_loglevel}
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "configure_chmpx_service_manager_file should return zero, not ${RET}"
return 1
fi

########
# 13. Installs the k2hdkc service manager configuration and enables it
# systemd controls k2hdkc
#
logger -t ${TAG} -p user.info "13. Installs the k2hdkc-trovectl service manager configuration and enables it"

install_service_manager_conf ${SERVICE_MANAGER} k2hdkc-trovectl
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "install_service_manager_conf should return zero, not ${RET}"
return 1
fi

########
# 14. Configures the k2hdkc-check-conf's service manager default configuration
# We recommend k2hdkc-check-conf processes work as a service by systemd.
#
logger -t ${TAG} -p user.info "14. Configures the k2hdkc-check-conf's service manager default configuration"

# Determines the service management file which file format depends on a service manager of the target OS
if test "${SERVICE_MANAGER}" = "systemd"; then
service_manager_file=${SRCDIR}/../service_manager/k2hdkc-check-conf.service
else
logger -t ${TAG} -p user.err "SERVICE_MANAGER must be either systemd, not ${SERVICE_MANAGER}"
return 1
fi
# Configures the k2hdkc's service manager default configuration
is_k2hdkc=1
configure_chmpx_service_manager_file ${SERVICE_MANAGER} ${service_manager_file} ${k2hr3_dkc_runuser} ${chmpx_conf_file} ${chmpx_msg_max} ${is_k2hdkc} ${k2hdkc_loglevel}
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "configure_chmpx_service_manager_file should return zero, not ${RET}"
return 1
fi

########
# 15. Installs the k2hdkc service manager configuration and enables it
# systemd controls k2hdkc
#
logger -t ${TAG} -p user.info "15. Installs the k2hdkc-check-conf service manager configuration and enables it"

if test -f "${SRCDIR}/../service_manager/scripts/k2hdkc-check-conf"; then
logger -t ${TAG} -p user.debug "sudo install -C -m 0755 -o root -v ${SRCDIR}/../service_manager/scripts/k2hdkc-check-conf /usr/libexec/k2hdkc-check-conf"
sudo install -C -m 0755 -o root -v ${SRCDIR}/../service_manager/scripts/k2hdkc-check-conf /usr/libexec/k2hdkc-check-conf
RESULT=$?
if test "${RESULT}" -ne 0; then
    logger -t ${TAG} -p user.err "RESULT should be zero, not ${RESULT}"
    return 1
fi
else
logger -t ${TAG} -p user.err "${SRCDIR}/../service_manager/scripts/k2hdkc-check-conf should exist"
return 1
fi

install_service_manager_conf ${SERVICE_MANAGER} k2hdkc-check-conf
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "install_service_manager_conf should return zero, not ${RET}"
return 1
fi

########
# 16. Configures the k2hdkc-check-conf's timer default configuration
# We recommend k2hdkc-check-conf processes work as a service by systemd.
#
logger -t ${TAG} -p user.info "16. Configures the k2hdkc-check-conf's timer default configuration"

# Determines the service management file which file format depends on a service manager of the target OS
if test "${SERVICE_MANAGER}" = "systemd"; then
service_manager_file=${SRCDIR}/../service_manager/k2hdkc-check-conf.timer
else
logger -t ${TAG} -p user.err "SERVICE_MANAGER must be either systemd, not ${SERVICE_MANAGER}"
return 1
fi
# Configures the k2hdkc's service manager default configuration
is_k2hdkc=1
configure_chmpx_service_manager_file ${SERVICE_MANAGER} ${service_manager_file} ${k2hr3_dkc_runuser} ${chmpx_conf_file} ${chmpx_msg_max} ${is_k2hdkc} ${k2hdkc_loglevel}
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "configure_chmpx_service_manager_file should return zero, not ${RET}"
return 1
fi

########
# 17. Installs the k2hdkc service manager configuration and enables it
# systemd controls k2hdkc
#
logger -t ${TAG} -p user.info "17. Installs the k2hdkc-check-conf timer configuration and enables it"
is_timer=1
install_service_manager_conf ${SERVICE_MANAGER} k2hdkc-check-conf ${is_timer}
RET=$?
if test "${RET}" -ne 0; then
logger -t ${TAG} -p user.err "install_service_manager_conf should return zero, not ${RET}"
return 1
fi

########
# Start the service!
#
logger -t ${TAG} -p user.debug "sudo systemctl restart chmpx.service"
if test -z "${DRYRUN-}"; then
sudo systemctl restart chmpx.service
RESULT=$?
if test "${RESULT}" -ne 0; then
    logger -t ${TAG} -p user.err "'sudo systemctl restart chmpx.service' should return zero, not ${RESULT}"
    return 1
fi

logger -t ${TAG} -p user.debug "sudo systemctl restart k2hdkc-trove.service"
sudo systemctl restart k2hdkc-trove.service
RESULT=$?
if test "${RESULT}" -ne 0; then
    logger -t ${TAG} -p user.err "'sudo systemctl restart k2hdkc-trove.service' should return zero, not ${RESULT}"
    return 1
fi
fi

logger -t ${TAG} -p user.info "trove.sh configure_systemd done"
return 0
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
