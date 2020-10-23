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
# A script to create a local.conf for devstack.
##
# NOTE:
#     This script fixes OpenStack version to Ussuri.
#

cat > ~/devstack/local.conf <<EOF
[[local|localrc]]
RECLONE=True
IPV4_ADDRS_SAFE_TO_USE="10.0.3.0/24"
#HOST_IP=10.0.2.15
IP_VERSION=4

enable_plugin horizon https://opendev.org/openstack/horizon.git stable/ussuri
enable_plugin trove https://opendev.org/openstack/trove.git stable/ussuri
enable_plugin trove-dashboard https://opendev.org/openstack/trove-dashboard stable/ussuri
enable_plugin k2hdkc_dbaas https://github.com/yahoojapan/k2hdkc_dbaas.git master
enable_plugin k2hr3_utils https://github.com/yahoojapan/k2hr3_utils.git master

LIBS_FROM_GIT+=,python-troveclient
DATABASE_PASSWORD=password
ADMIN_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=password
RABBIT_PASSWORD=password
LOGFILE=\$DEST/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=False
LOGDAYS=1

# Pre-requisites
ENABLED_SERVICES=rabbit,mysql,key

# Horizon
enable_service horizon

# Nova
enable_service n-api
enable_service n-cpu
enable_service n-cond
enable_service n-sch
enable_service n-api-meta
enable_service placement-api
enable_service placement-client

# Glance
enable_service g-api
enable_service g-reg

# Cinder
enable_service cinder
enable_service c-api
enable_service c-vol
enable_service c-sch

# Neutron
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta

# Swift
ENABLED_SERVICES+=,swift
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=\$DEST/data
# Swift default 5G
SWIFT_MAX_FILE_SIZE=5368709122
# Swift disk size 10G
SWIFT_LOOPBACK_DISK_SIZE=10G

# TROVE
TROVE_ENABLE_IMAGE_BUILD=false

# TROVE_DASHBOARD
TROVE_CLIENT_BRANCH=stable/ussuri
TROVE_DASHBOARD_BRANCH=stable/ussuri

# Python3
USE_PYTHON3=True
PYTHON3_VERSION=3.6

EOF

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
