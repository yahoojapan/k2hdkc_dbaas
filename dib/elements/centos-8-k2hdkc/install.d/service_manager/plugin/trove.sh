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

#
# function : setup service manager
#
function setup_service_manager {
	logger -t ${TAG} -p user.info "trove.sh configure_systemd"

	########
	# 8. Configures the k2hdkc-trove service manager default configuration
	#
	logger -t ${TAG} -p user.info "8. Configures the k2hdkc-trove service manager default configuration"

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
	# 9. Installs the k2hdkc-trove service helper configuration and enables it
	# systemd controls k2hdkc
	#
	logger -t ${TAG} -p user.info "9. Installs the k2hdkc-trove service helper configuration and enables it"

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

	logger -t ${TAG} -p user.info "trove.sh configure_systemd done"
	return 0
}

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
