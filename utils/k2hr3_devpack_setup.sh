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
# AUTHOR:   Takeshi Nakatani
# CREATE:   Mon Sep 14 2020
# REVISION:
#

#
# This script is one tool for building a test execution environment
# for the K2HDKC DBaaS on Trove (k2hdkc dbaas) system.
# This script will automatically build a K2HR3 system on one of the
# running Trove (OpenStack) Virtual Machines.
# The K2HR3 system that is built boots in a specialized state for Trove.
#

#----------------------------------------------------------
# Environments
#----------------------------------------------------------
CMDLINE_PROCESS_NAME=$0
PROGRAM_NAME=`basename ${CMDLINE_PROCESS_NAME}`
SCRIPTPATH=`dirname ${CMDLINE_PROCESS_NAME}`
CURRENT_DIR=`cd ${SCRIPTPATH}; pwd`
CURRENT_TIME='date +%Y-%m-%d-%H:%M:%S,%3N'

#
# Escape sequence
#
if [ -t 1 ]; then
	CREV=$(printf '\033[7m')
	CRED=$(printf '\033[31m')
	CGRN=$(printf '\033[32m')
	CDEF=$(printf '\033[0m')
else
	CREV=""
	CRED=""
	CGRN=""
	CDEF=""
fi

#----------------------------------------------------------
# Functions
#----------------------------------------------------------
func_usage()
{
	#
	# $1:	Program name
	#
	echo ""
	echo "Usage:  $1 [--no_clear(-nc) | --clear(-c)]"
	echo "        [--use_parent_auto(-upa) | --use_parent_custom(-upc) <hostname or ip address> | --use_parent_nic(-upn) | --use_parent_name(-upn)]"
	echo "        [--up_wait_count(-uwc)]"
	echo "        [--help(-h)]"
	echo ""
	echo "        --clear(-c)                       Clear all resources about K2HR3 systems in OpenStack before setup(default)"
	echo "        --no_clear(-nc)                   Not clear all resources about K2HR3 systems in OpenStack before setup"
	echo "        --use_parent_auto(-upa)           Hotname(IP address) is automatically selected optimally for HAProxy(default)"
	echo "        --use_parent_custom(-upc) <host>  Specify hostname or IP address for HAProxy"
	echo "        --use_parent_nic(-upnic)          Force to use default NIC IP address for HAProxy"
	echo "        --use_parent_name(-upname)        Force to use local hostname(IP address) for HAProxy"
	echo "        --up_wait_count(-uwc) <count>     Specify the waiting try count (1 time is 10sec) until the instance up, and 0(default) for no upper limit."
	echo "        --help(-h)                        print help"
	echo ""
}

#----------------------------------------------------------
# Options
#----------------------------------------------------------
#
# Check options
#
OPT_DO_CLEAR=-1
OPT_UP_WAIT_COUNT=-1
OPT_PARENT_TYPE=
TYPE_CUSTOM_PARENT_HOSTNAME=
TYPE_CUSTOM_PARENT_IP=
while [ $# -ne 0 ]; do
	if [ "X$1" = "X" ]; then
		break

	elif [ "X$1" = "X-h" -o "X$1" = "X-H" -o "X$1" = "X--help" -o "X$1" = "X--HELP" ]; then
		func_usage $PROGRAM_NAME
		exit 0

	elif [ "X$1" = "X--clear" -o "X$1" = "X--CLEAR" -o "X$1" = "X-c" -o "X$1" = "X-C" ]; then
		if [ ${OPT_DO_CLEAR} -ne -1 ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--clear\" or \"--no_clear\" options.${CDEF}" 1>&2
			exit 1
		fi
		OPT_DO_CLEAR=1

	elif [ "X$1" = "X--no_clear" -o "X$1" = "X--NO_CLEAR" -o "X$1" = "X-nc" -o "X$1" = "X-NC" ]; then
		if [ ${OPT_DO_CLEAR} -ne -1 ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--clear\" or \"--no_clear\" options.${CDEF}" 1>&2
			exit 1
		fi
		OPT_DO_CLEAR=0

	elif [ "X$1" = "X--use_parent_auto" -o "X$1" = "X--USE_PARENT_AUTO" -o "X$1" = "X-upa" -o "X$1" = "X-UPA" ]; then
		if [ "X${OPT_PARENT_TYPE}" != "X" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--use_parent_auto\" or \"--use_parent_custom\" or \"--use_parent_nic\" or \"--use_parent_name\" options.${CDEF}" 1>&2
			exit 1
		fi
		OPT_PARENT_TYPE="Auto"

	elif [ "X$1" = "X--use_parent_custom" -o "X$1" = "X--USE_PARENT_CUSTOM" -o "X$1" = "X-upc" -o "X$1" = "X-UPC" ]; then
		if [ "X${OPT_PARENT_TYPE}" != "X" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--use_parent_auto\" or \"--use_parent_custom\" or \"--use_parent_nic\" or \"--use_parent_name\" options.${CDEF}" 1>&2
			exit 1
		fi
		shift
		if [ "X$1" = "X" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` \"--use_parent_custom(-upc)\" option needs parameter(hostname or ip address).${CDEF}" 1>&2
			exit 1
		fi
		OPT_PARENT_TYPE="Custom"
		TYPE_CUSTOM_PARENT_HOSTNAME=
		TYPE_CUSTOM_PARENT_IP=$1

	elif [ "X$1" = "X--use_parent_nic" -o "X$1" = "X--USE_PARENT_NIC" -o "X$1" = "X-upnic" -o "X$1" = "X-UPNIC" ]; then
		if [ "X${OPT_PARENT_TYPE}" != "X" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--use_parent_auto\" or \"--use_parent_custom\" or \"--use_parent_nic\" or \"--use_parent_name\" options.${CDEF}" 1>&2
			exit 1
		fi
		OPT_PARENT_TYPE="Nic"

	elif [ "X$1" = "X--use_parent_name" -o "X$1" = "X--USE_PARENT_NAME" -o "X$1" = "X-upname" -o "X$1" = "X-UPNAME" ]; then
		if [ "X${OPT_PARENT_TYPE}" != "X" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--use_parent_auto\" or \"--use_parent_custom\" or \"--use_parent_nic\" or \"--use_parent_name\" options.${CDEF}" 1>&2
			exit 1
		fi
		OPT_PARENT_TYPE="Name"


	elif [ "X$1" = "X--up_wait_count" -o "X$1" = "X--UP_WAIT_COUNT" -o "X$1" = "X-uwc" -o "X$1" = "X-UWC" ]; then
		if [ ${OPT_UP_WAIT_COUNT} -ne -1 ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already specified \"--up_wait_count\" option.${CDEF}" 1>&2
			exit 1
		fi
		shift
		if [ "X$1" = "X" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` \"--up_wait_count(-uwc)\" option needs parameter(number).${CDEF}" 1>&2
			exit 1
		fi
		NUMBER_VALUE_TMP=`expr $1 + 1 2>/dev/null`
		if [ $? -ne 0 ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` \"--up_wait_count(-uwc)\" option parameter($1) must be 0 or positive number.${CDEF}" 1>&2
			exit 1
		fi
		if [ ${NUMBER_VALUE_TMP} -lt 1 ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` \"--up_wait_count(-uwc)\" option parameter($1) must be 0 or positive number.${CDEF}" 1>&2
			exit 1
		fi
		OPT_UP_WAIT_COUNT=$1

	else
		echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` $1 option is unknown.${CDEF}" 1>&2
		exit 1
	fi
	shift
done

#
# Set default value
#
if [ ${OPT_DO_CLEAR} -eq -1 ]; then
	OPT_DO_CLEAR=1
fi
if [ -z "${OPT_PARENT_TYPE}" ]; then
	OPT_PARENT_TYPE="Auto"
fi
if [ ${OPT_UP_WAIT_COUNT} -eq -1 ]; then
	OPT_UP_WAIT_COUNT=0
fi

echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Start to setup K2HR3 for Trove K2HDKC${CDEF}" 1>&2

#----------------------------------------------------------
# Variables
#----------------------------------------------------------
#
# Python
#
python --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
	PYBIN="python"
else
	python3 --version >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		PYBIN="python3"
	else
		echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` The python program could not be found.${CDEF}" 1>&2
		exit 1
	fi
fi

#----------------------------------------------------------
# Decision : Hostname and IP address
#----------------------------------------------------------
#
# Get parent hostname and IP address from local hostname
# (All cases are needed this because it used by openstack identiy url)
#
TYPE_NAME_PARENT_HOSTNAME=`hostname`
TYPE_NAME_PARENT_IP=
if [ -z "${TYPE_NAME_PARENT_HOSTNAME}" ]; then
	echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Could not get local hostname." 1>&2
else
	which dig >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Not found dig command, you should install dig command(ex. bind-utils on centos)." 1>&2
		TYPE_NAME_PARENT_HOSTNAME=
	else
		TYPE_NAME_PARENT_IP=`dig ${TYPE_NAME_PARENT_HOSTNAME} | grep ${TYPE_NAME_PARENT_HOSTNAME} | grep -v '^;' | sed -e 's/IN A//g' | awk '{print $3}'`
		if [ -z "${TYPE_NAME_PARENT_IP}" ]; then
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Could not get IP address for local hostname." 1>&2
			TYPE_NAME_PARENT_HOSTNAME=
		else
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Local hostname is ${TYPE_NAME_PARENT_HOSTNAME} and IP address is ${TYPE_NAME_PARENT_IP}." 1>&2
		fi
	fi
fi

#
# Get parent IP address from default nic
#
TYPE_NIC_PARENT_HOSTNAME=
TYPE_NIC_PARENT_IP=
if [ "X${OPT_PARENT_TYPE}" = "XAuto" -o "X${OPT_PARENT_TYPE}" = "XNic" ]; then
	PARENT_IP_NIC_NAME=`ip -f inet route | grep default  | awk '{print $5}'`
	TYPE_NIC_PARENT_IP=`ip -f inet addr show ${PARENT_IP_NIC_NAME} | grep inet | awk '{print $2}' | sed 's#/# #g' | awk '{print $1}'`
	if [ -z "${TYPE_NIC_PARENT_IP}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Could not get IP address from default NIC." 1>&2
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Default NIC IP address is ${TYPE_NIC_PARENT_IP}." 1>&2
		TYPE_NIC_PARENT_HOSTNAME=${TYPE_NIC_PARENT_IP}
	fi
fi

#
# Decide parent hostname and ip address and IP address for identity URL
#
IDENTIRY_HOST=${TYPE_NAME_PARENT_IP}
K2HR3_EXTERNAL_HOSTNAME=
K2HR3_EXTERNAL_HOSTIP=
if [ "X${OPT_PARENT_TYPE}" = "XCustom" ]; then
	echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide hostname or IP address(${TYPE_CUSTOM_PARENT_IP}) for external access by \"--use_parent_custom\" option." 1>&2
	K2HR3_EXTERNAL_HOSTNAME=${TYPE_CUSTOM_PARENT_HOSTNAME}
	K2HR3_EXTERNAL_HOSTIP=${TYPE_CUSTOM_PARENT_IP}

	if [ -z "${IDENTIRY_HOST}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Not found local host ip address, then use specified host(${TYPE_CUSTOM_PARENT_IP}) for Identiy IP address." 1>&2
		IDENTIRY_HOST=${TYPE_CUSTOM_PARENT_IP}
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide Identiy IP address(${TYPE_NAME_PARENT_IP}) from local hostname." 1>&2
	fi

elif [ "X${OPT_PARENT_TYPE}" = "XAuto" ]; then
	if [ -z "${TYPE_NIC_PARENT_IP}" ]; then
		if [ -z "${TYPE_NAME_PARENT_IP}" ]; then
			echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not find IP address for host, you should specify \"--use_parent_custom\" or \"--use_parent_nic\" or \"--use_parent_name\" options for deciding it.${CDEF}" 1>&2
			exit 1
		fi

		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide hostname/IP address(${TYPE_NAME_PARENT_HOSTNAME}/${TYPE_NAME_PARENT_IP}) for external access from local hostanme." 1>&2
		K2HR3_EXTERNAL_HOSTNAME=${TYPE_NAME_PARENT_HOSTNAME}
		K2HR3_EXTERNAL_HOSTIP=${TYPE_NAME_PARENT_IP}

		if [ -z "${IDENTIRY_HOST}" ]; then
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Not found local host ip address, then use local host IP address(${TYPE_NAME_PARENT_IP}) for Identiy IP address." 1>&2
			IDENTIRY_HOST=${TYPE_NAME_PARENT_IP}
		else
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide Identiy IP address(${TYPE_NAME_PARENT_IP}) from local hostname." 1>&2
		fi
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide IP address(${TYPE_NIC_PARENT_IP}) for external access from default NIC." 1>&2
		K2HR3_EXTERNAL_HOSTNAME=${TYPE_NIC_PARENT_HOSTNAME}
		K2HR3_EXTERNAL_HOSTIP=${TYPE_NIC_PARENT_IP}

		if [ -z "${IDENTIRY_HOST}" ]; then
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Not found local host ip address, then use default NIC IP address(${TYPE_NIC_PARENT_IP}) for Identiy IP address." 1>&2
			IDENTIRY_HOST=${TYPE_NIC_PARENT_IP}
		else
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide Identiy IP address(${TYPE_NAME_PARENT_IP}) from local hostname." 1>&2
		fi
	fi

elif [ "X${OPT_PARENT_TYPE}" = "XName" ]; then
	echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide hostname/IP address(${TYPE_NAME_PARENT_HOSTNAME}/${TYPE_NAME_PARENT_IP}) for external access from local hostanme(\"--use_parent_name\" option)." 1>&2
	K2HR3_EXTERNAL_HOSTNAME=${TYPE_NAME_PARENT_HOSTNAME}
	K2HR3_EXTERNAL_HOSTIP=${TYPE_NAME_PARENT_IP}

	if [ -z "${IDENTIRY_HOST}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Not found local host ip address, then use local host IP address(${TYPE_NAME_PARENT_IP}) for Identiy IP address." 1>&2
		IDENTIRY_HOST=${TYPE_NAME_PARENT_IP}
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide Identiy IP address(${TYPE_NAME_PARENT_IP}) from local hostname." 1>&2
	fi

elif [ "X${OPT_PARENT_TYPE}" = "XNic" ]; then
	echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide IP address(${TYPE_NIC_PARENT_IP}) for external access from default NIC(\"--use_parent_nic\" option)." 1>&2
	K2HR3_EXTERNAL_HOSTNAME=${TYPE_NIC_PARENT_HOSTNAME}
	K2HR3_EXTERNAL_HOSTIP=${TYPE_NIC_PARENT_IP}

	if [ -z "${IDENTIRY_HOST}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Not found local host ip address, then use default NIC IP address(${TYPE_NIC_PARENT_IP}) for Identiy IP address." 1>&2
		IDENTIRY_HOST=${TYPE_NIC_PARENT_IP}
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Decide Identiy IP address(${TYPE_NAME_PARENT_IP}) from local hostname." 1>&2
	fi
fi

#----------------------------------------------------------
# Check devpack directory in k2hr3 utilities and utils in k2hdkc_dbaas
#----------------------------------------------------------
#
# Check k2hr3_utils/devpack directory
#
K2HR3_DEVPACK_NAME="devpack"
K2HR3_UTILS_DIR="${CURRENT_DIR}/k2hr3_utils"
K2HR3_DEVPACK_DIR="${K2HR3_UTILS_DIR}/${K2HR3_DEVPACK_NAME}"
if [ ! -d ${K2HR3_DEVPACK_DIR} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not find ${K2HR3_DEVPACK_DIR} directory.${CDEF}" 1>&2
	exit 1
fi

#
# Check k2hdkc_dbaas/utils directory
#
K2HDKC_DBAAS_UTILS_DIR="${CURRENT_DIR}/k2hdkc_dbaas/utils"
if [ ! -d ${K2HDKC_DBAAS_UTILS_DIR} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not find ${K2HDKC_DBAAS_UTILS_DIR} directory.${CDEF}" 1>&2
	exit 1
fi

#----------------------------------------------------------
# Set OpenStack Environments for trove
#----------------------------------------------------------
# [NOTE]
# This script uses "trove" user and "service" project.
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Setup environments for trove user to build K2HR3 system.${CDEF}" 1>&2

PROJECT_NAME="service"
export OS_AUTH_URL="http://${IDENTIRY_HOST}/identity"
export OS_PROJECT_NAME="${PROJECT_NAME}"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_ID="default"
export OS_USERNAME="trove"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
unset OS_TENANT_ID
unset OS_TENANT_NAME

if [ -z "${OS_PASSWORD}" ]; then
	LOCAL_CONF_FILE="/opt/stack/devstack/local.conf"
	if [ -f ${LOCAL_CONF_FILE} ]; then
		OS_PASSWORD=`grep ADMIN_PASSWORD ${LOCAL_CONF_FILE} 2>/dev/null | cut -d '=' -f 2 2>/dev/null`
	fi
	if [ -z "${OS_PASSWORD}" ]; then
		echo ""
		echo -n "* Please input \"trove\" user passphrase(no input is displayed) : "
		read -sr OS_PASSWORD_INPUT
		echo ""
		OS_PASSWORD=${OS_PASSWORD_INPUT}
	else
		echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} Found ${LOCAL_CONF_FILE} file and it has ADMIN_PASSWORD value, so use it for trove user passphrase.${CDEF}" 1>&2
	fi
else
	echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` OS_PASSWORD environment is set, use it for trove user passphrase." 1>&2
fi
export OS_PASSWORD

#
# Get Project ID ( = 'service')
#
PROJECT_ID=`openstack project list -f value | grep ${PROJECT_NAME} | awk '{print $1}'`
if [ -z "${PROJECT_ID}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get project id for \"${PROJECT_NAME}\" project.${CDEF}" 1>&2
	exit 1
fi
export OS_PROJECT_ID="${PROJECT_ID}"


#----------------------------------------------------------
# Check and clear existed OpenStack resources
#----------------------------------------------------------
K2HR3_HOSTNAME="k2hdkc-dbaas-k2hr3"
KEYPAIR_NAME="k2hr3key"
K2HR3_DEVPACK_CONF_DIR="${K2HR3_DEVPACK_DIR}/conf"
PRIVATE_KEY_PATH="${K2HR3_DEVPACK_CONF_DIR}"
PRIVATE_KEY_FILE="${PRIVATE_KEY_PATH}/${KEYPAIR_NAME}_private.pem"
K2HR3_SECURITY_GROUP_NAME="k2hdkc-dbaas-k2hr3-secgroup"
HAPROXY_CFG_FILE="${K2HR3_DEVPACK_CONF_DIR}/haproxy.cfg"
HAPROXY_LOG_FILE="${K2HR3_DEVPACK_DIR}/log/haproxy.log"

if [ ${OPT_DO_CLEAR} -eq 1 ]; then
	#
	# Check Virtual Machine for K2HR3 system and remove it
	#
	K2HR3_HOST_TMP=`openstack server list | grep ${K2HR3_HOSTNAME}`
	if [ ! -z "${K2HR3_HOST_TMP}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Already run \"${K2HR3_HOSTNAME}\" instance, then remove it." 1>&2
		openstack server delete ${K2HR3_HOSTNAME}
		sleep 10
	fi

	#
	# Check private key file(pem) and remove it
	#
	if [ -f ${PRIVATE_KEY_FILE} ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` \"${PRIVATE_KEY_FILE}\" for \"${KEYPAIR_NAME}\" keypair private file exists, then remove it." 1>&2
		rm ${PRIVATE_KEY_FILE}
		if [ $? -ne 0 ]; then
			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Could not remove \"${PRIVATE_KEY_FILE}\" for \"${KEYPAIR_NAME}\" keypair private file." 1>&2
			exit 1
		fi
	fi

	#
	# Check k2hr3key keypair in OpenStack
	#
	KEYPAIR_TMP=`openstack keypair list -f value | grep ${KEYPAIR_NAME}`
	if [ ! -z "${KEYPAIR_TMP}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Already has \"${KEYPAIR_NAME}\" keypair, then remove it." 1>&2
		openstack keypair delete ${KEYPAIR_NAME}
		sleep 10
	fi

	#
	# Check K2HR3 security group in OpenStack
	#
	SECURITY_GROUP_TMP=`openstack security group list | grep ${K2HR3_SECURITY_GROUP_NAME}`
	if [ ! -z "${SECURITY_GROUP_TMP}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Already has \"${K2HR3_SECURITY_GROUP_NAME}\" security group, then remove it." 1>&2
		#
		# Check security group ids for k2hdkc-dbaas-k2hr3-secgroup
		#
		SECURITY_GROUP_IDS=`openstack security group list | grep ${K2HR3_SECURITY_GROUP_NAME} | tr -d '|' | awk '{print $1}'`
		for _one_group_id in ${SECURITY_GROUP_IDS}; do
			#
			# Remove all rules in security group
			#
			SECURITY_RULES_IN_GROUP_ID=`openstack security group rule list -f value -c ID ${_one_group_id}`
			for _one_rule_id in ${SECURITY_RULES_IN_GROUP_ID}; do
				echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Remove rule(${_one_rule_id}) in \"${K2HR3_SECURITY_GROUP_NAME}\" security group." 1>&2
				openstack security group rule delete ${_one_rule_id}
			done

			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Remove security group is(${_one_group_id}) in \"${K2HR3_SECURITY_GROUP_NAME}\"." 1>&2
			openstack security group delete ${_one_group_id}
		done
	fi

	#
	# Check and stop old HAProxy
	#
	OLD_HAPROXY_PIDS=`ps ax | grep haproxy | grep "${HAPROXY_CFG_FILE}" | grep -v grep | awk '{print $1}'`
	if [ ! -z ${OLD_HAPROXY_PIDS} ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Found old HAProxys(${OLD_HAPROXY_PIDS}), then stop these." 1>&2
		kill -TERM ${OLD_HAPROXY_PIDS}
	fi
fi

#----------------------------------------------------------
# Create related OpenStack resources
#----------------------------------------------------------
#
# Get Flavor ID ( = 'ds1G' )
#
FLAVOR_ID=`openstack flavor list -f value | grep ds1G | awk '{print $1}'`
if [ -z "${FLAVOR_ID}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get flavor id for \"ds1G\".${CDEF}" 1>&2
	exit 1
fi

#
# Get Network ID ( = 'private' )
#
NETWORK_ID=`openstack network list -f value | grep private | awk '{print $1}'`
if [ -z "${NETWORK_ID}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get network id for \"private\".${CDEF}" 1>&2
	exit 1
fi

#
# Image upload ( Ubuntu 18.04 )
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Download and register os image(ubuntu) for K2HR3 system.${CDEF}" 1>&2

IMAGE_NAME="k2hdkc-dbaas-k2hr3-ubuntu-1804"
EXIST_IMAGE_TMP=`openstack image list -f value | grep ${IMAGE_NAME}`
if [ ! -z "${EXIST_IMAGE_TMP}" ]; then
	echo "${CRED}${CREV}[WARN]${CDEF}${CRED} `${CURRENT_TIME}` Already has ${IMAGE_NAME} image, thus skip image upload.${CDEF}" 1>&2
else
	wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
	openstack image create ${IMAGE_NAME} --disk-format qcow2 --container-format bare --public < bionic-server-cloudimg-amd64.img
	rm -f bionic-server-cloudimg-amd64.img
fi

#
# Get Image ID ( = 'Ubuntu1804' )
#
IMAGE_ID=`openstack image list -f value | grep ${IMAGE_NAME} | awk '{print $1}'`
if [ -z "${IMAGE_ID}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get \"${IMAGE_NAME}\" image id.${CDEF}" 1>&2
	exit 1
fi

#
# Create Keypair
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Make key pair for K2HR3 system to access by ssh manually.${CDEF}" 1>&2

if [ -f ${PRIVATE_KEY_FILE} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` \"${PRIVATE_KEY_FILE}\" for \"${KEYPAIR_NAME}\" keypair private file exists.${CDEF}" 1>&2
	exit 1
fi
KEYPAIR_TMP=`openstack keypair list -f value | grep ${KEYPAIR_NAME}`
if [ ! -z "${KEYPAIR_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already has \"${KEYPAIR_NAME}\" keypair.${CDEF}" 1>&2
	exit 1
fi

openstack keypair create --private-key ${PRIVATE_KEY_FILE} ${KEYPAIR_NAME}

KEYPAIR_TMP=`openstack keypair list -f value | grep ${KEYPAIR_NAME}`
if [ -z "${KEYPAIR_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${KEYPAIR_NAME}\" keypair.${CDEF}" 1>&2
	exit 1
fi
if [ ! -f ${PRIVATE_KEY_FILE} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${PRIVATE_KEY_FILE}\" for \"${KEYPAIR_NAME}\" keypair private file.${CDEF}" 1>&2
	exit 1
fi
chmod 0600 ${PRIVATE_KEY_FILE}

#
# Create Security Group
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Create security group(k2hdkc-dbaas-k2hr3-secgroup) for K2HR3 system.${CDEF}" 1>&2

SECURITY_GROUP_TMP=`openstack security group list | grep ${K2HR3_SECURITY_GROUP_NAME}`
if [ ! -z "${SECURITY_GROUP_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already has \"${K2HR3_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group create --description 'security group for k2hr3 system' ${K2HR3_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${K2HR3_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 22:22 --protocol tcp --description 'ssh port' ${K2HR3_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add ssh port(22) to \"${K2HR3_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 80:80 --protocol tcp --description 'k2hr3 app http port' ${K2HR3_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add k2hr3 app http port(80) to \"${K2HR3_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 18080:18080 --protocol tcp --description 'k2hr3 api http port' ${K2HR3_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add k2hr3 api http port(18080) to \"${K2HR3_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

#
# Make user data file
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Create a instance(k2hdkc-dbaas-k2hr3)  for K2HR3 system.${CDEF}" 1>&2

USERDATA_FILE="/tmp/k2hr3_userdata.txt"
cat <<EOF > ${USERDATA_FILE}
#cloud-config
password: ubuntu
chpasswd: { expire: False }
ssh_pwauth: True
EOF

#
# Create Virtual Machine for K2HR3 system
#
K2HR3_HOSTNAME="k2hdkc-dbaas-k2hr3"

K2HR3_HOST_TMP=`openstack server list | grep ${K2HR3_HOSTNAME}`
if [ ! -z "${K2HR3_HOST_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already run \"${K2HR3_HOSTNAME}\" instance.${CDEF}" 1>&2
	exit 1
fi

openstack server create --flavor ${FLAVOR_ID} --image ${IMAGE_ID} --key-name ${KEYPAIR_NAME} --user-data ${USERDATA_FILE} --security-group ${K2HR3_SECURITY_GROUP_NAME} --network ${NETWORK_ID} ${K2HR3_HOSTNAME}
rm -f ${USERDATA_FILE}

#
# Wait for instance up(status becomes ACTIVE)
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Wait for instance(k2hdkc-dbaas-k2hr3) up.${CDEF}" 1>&2
if [ ${OPT_UP_WAIT_COUNT} -eq 0 ]; then
	WAIT_COUNT=-1
else
	WAIT_COUNT=${OPT_UP_WAIT_COUNT}
fi
IS_INSTANCE_UP=0
while [ ${WAIT_COUNT} -gt 0 -o ${WAIT_COUNT} -eq -1 ]; do
	sleep 10
	INSTANCE_STATUS=`openstack server list | grep ${K2HR3_HOSTNAME} | tr -d '|' | awk '{print $3}'`
	if [ "X${INSTANCE_STATUS}" = "XACTIVE" ]; then
		IS_INSTANCE_UP=1
		break;
	fi
	if [ ${WAIT_COUNT} -ne -1 ]; then
		WAIT_COUNT=`expr ${WAIT_COUNT} - 1`
	fi
done
if [ ${IS_INSTANCE_UP} -ne 1 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Instance \"${K2HR3_HOSTNAME}\" did not start until the timeout.${CDEF}" 1>&2
	exit 1
fi

#
# Get Server ID and IP Address
#
K2HR3_SERVER_ID=`openstack server list -f value | grep ${K2HR3_HOSTNAME} | grep ACTIVE | awk '{print $1}'`
if [ -z "${K2HR3_SERVER_ID}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${K2HR3_HOSTNAME}\" instance.${CDEF}" 1>&2
	exit 1
fi

K2HR3_IP_ADDRESS=`openstack server show ${K2HR3_SERVER_ID} -f value | grep 'private=' | sed -e 's/private=//g'`
if [ -z "${K2HR3_IP_ADDRESS}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get IP address for \"${K2HR3_HOSTNAME}\" instance.${CDEF}" 1>&2
	exit 1
fi

#----------------------------------------------------------
# Create K2HR3 system
#----------------------------------------------------------
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Setup programs on instance(k2hdkc-dbaas-k2hr3) for K2HR3 system.${CDEF}" 1>&2

#
# SSH options
#
SSH_OPTION="StrictHostKeyChecking=no"
USER_AND_HOST="ubuntu@${K2HR3_IP_ADDRESS}"

#
# Check and wait for instance SSH up
#
echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Wait for instance(k2hdkc-dbaas-k2hr3) SSH up." 1>&2
if [ ${OPT_UP_WAIT_COUNT} -eq 0 ]; then
	WAIT_COUNT=-1
else
	WAIT_COUNT=${OPT_UP_WAIT_COUNT}
fi
IS_INSTANCE_SSH_UP=0
while [ ${WAIT_COUNT} -gt 0 -o ${WAIT_COUNT} -eq -1 ]; do
	#
	# Use dummy command
	#
	ssh -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} ${USER_AND_HOST} "pwd >/dev/null" >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		IS_INSTANCE_SSH_UP=1
		break;
	fi
	if [ ${WAIT_COUNT} -ne -1 ]; then
		WAIT_COUNT=`expr ${WAIT_COUNT} - 1`
	fi
	sleep 10
done
if [ ${IS_INSTANCE_SSH_UP} -ne 1 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Instance \"${K2HR3_HOSTNAME}\" SSH did not up until the timeout.${CDEF}" 1>&2
	exit 1
fi

#
# Copy custom files for devpack in K2HR3 Utilities
#
if [ -f ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_api.templ ]; then
	cp -p ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_api.templ ${K2HR3_DEVPACK_CONF_DIR}/custom_production_api.templ
	if [ $? -ne 0 ]; then
		echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not copy ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_api.templ file.${CDEF}" 1>&2
		exit 1
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Copied ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_api.templ to ${K2HR3_DEVPACK_CONF_DIR}/custom_production_api.templ." 1>&2
	fi
fi
if [ -f ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_app.templ ]; then
	cp -p ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_app.templ ${K2HR3_DEVPACK_CONF_DIR}/custom_production_app.templ
	if [ $? -ne 0 ]; then
		echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not copy ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_app.templ file.${CDEF}" 1>&2
		exit 1
	else
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Copied ${K2HDKC_DBAAS_UTILS_DIR}/custom_production_app.templ to ${K2HR3_DEVPACK_CONF_DIR}/custom_production_app.templ." 1>&2
	fi
fi

#
# Make devpack archive file
#
K2HR3_PACK_TGZ="${K2HR3_DEVPACK_NAME}.tgz"
tar cvf - -C ${K2HR3_UTILS_DIR} ${K2HR3_DEVPACK_NAME} | gzip - > /tmp/${K2HR3_PACK_TGZ}

#
# Copy file
#
scp -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} /tmp/${K2HR3_PACK_TGZ} ${USER_AND_HOST}:/home/ubuntu
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not copy k2hr3 pack to \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	rm -f /tmp/${K2HR3_PACK_TGZ}
	exit 1
fi
rm -f /tmp/${K2HR3_PACK_TGZ}

#
# Expand file
#
ssh -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} ${USER_AND_HOST} "tar xvfz ${K2HR3_PACK_TGZ}"
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not expand \"${K2HR3_PACK_TGZ}\" file on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi

#
# Run k2hr3_utils/devpack/bin/devpack.sh
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Start to run all K2HR3 system on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2

ssh -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} ${USER_AND_HOST} "${K2HR3_DEVPACK_NAME}/bin/devpack.sh -ni -nc --run_user nobody --openstack_region ${OS_REGION_NAME} --keystone_url http://${IDENTIRY_HOST}/identity --app_port 80 --app_port_external 28080 --app_host ${K2HR3_IP_ADDRESS} --app_host_external ${K2HR3_EXTERNAL_HOSTIP} --api_port 18080 --api_port_external 18080 --api_host ${K2HR3_IP_ADDRESS} --api_host_external ${K2HR3_EXTERNAL_HOSTIP}"
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Failed to run k2hr3 system on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Succeed to run all K2HR3 system on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2

#
# Get haproxy example configuration
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Setup haproxy to access K2HR3 system from parent host.${CDEF}" 1>&2

if [ -f ${HAPROXY_CFG_FILE} ]; then
	rm -f ${HAPROXY_CFG_FILE}
fi
if [ -f ${HAPROXY_LOG_FILE} ]; then
	rm -f ${HAPROXY_LOG_FILE}
fi

scp -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} ${USER_AND_HOST}:/home/ubuntu/${K2HR3_DEVPACK_NAME}/conf/haproxy_example.cfg ${HAPROXY_CFG_FILE}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get haproxy configuration file from \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi
if [ ! -f ${HAPROXY_CFG_FILE} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get haproxy configuration file from \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi

#----------------------------------------------------------
# Run Haproxy
#----------------------------------------------------------
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Start to run haproxy process on \"${PARENT_HOSTNAME}\".${CDEF}" 1>&2

haproxy -f ${HAPROXY_CFG_FILE} > ${HAPROXY_LOG_FILE} 2>&1 &
sleep 1

HAPROXY_PID=$!
ps ax | awk '{print $1}' | grep ${HAPROXY_PID} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not run haproxy on \"${PARENT_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Succeed to run haproxy on \"${PARENT_HOSTNAME}\".${CDEF}" 1>&2

#----------------------------------------------------------
# Change private IP address to K2HR3
#----------------------------------------------------------
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Restart horizon httpd for changing k2hr3 private IP address.${CDEF}" 1>&2

HORIZON_BASE_DIR="${K2HR3_UTILS_DIR}/../horizon"
LOCAL_SETTINGS_PY_FILE="${HORIZON_BASE_DIR}/openstack_dashboard/local/local_settings.py"
perl -pi -e "BEGIN{undef $/;} s|\[\"k2hr3_from_private_network\"\].*\n\s+\"http_scheme\": \"(\S+)\",\n\s+\"host\": \"(\S+)\",|\[\"k2hr3_from_private_network\"\] = {\n    \"http_scheme\": \"\$1\",\n    \"host\": \"${K2HR3_IP_ADDRESS}\",|smg" ${LOCAL_SETTINGS_PY_FILE}
if [ $? -ne 0 ] ; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Substring k2hr3_from_private_network host is failed.${CDEF}" 1>&2
	exit 1
fi

pushd ${HORIZON_BASE_DIR}
${PYBIN} manage.py compress
${PYBIN} manage.py collectstatic --noinput
popd
sudo systemctl restart httpd
if [ $? -ne 0 ] ; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not restart httpd for horizon.${CDEF}" 1>&2
	exit 1
fi

echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Succeed to restart httpd for horizon.${CDEF}" 1>&2

#----------------------------------------------------------
# Additional settings for test K2HDKC slave node
#----------------------------------------------------------
# [NOTE] Be careful!
# After this processes, the user and project are switched to demo:demo.
# The passphrase for demo user is as same as trove user's one.
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Set security group(k2hdkc-slave-sec) on demo user for K2HDKC slave node.${CDEF}" 1>&2

PROJECT_NAME="demo"
export OS_PROJECT_NAME="${PROJECT_NAME}"
export OS_USERNAME="demo"

#
# Reset project id for demo user/demo project
#
unset OS_PROJECT_ID
PROJECT_ID=`openstack project list -f value | grep ${PROJECT_NAME} | awk '{print $1}'`
if [ -z "${PROJECT_ID}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get project id for \"${PROJECT_NAME}\" project.${CDEF}" 1>&2
	exit 1
fi
export OS_PROJECT_ID="${PROJECT_ID}"

#
# Check and remove existed security group for K2HDKC Slave node
#
# [NOTE]
# This should be checked in the same place as the K2HR3 security
# group check, but since the user and project ID etc are different,
# thus we will do it here.
#
SLAVE_SECURITY_GROUP_NAME="k2hdkc-slave-sec"

if [ ${OPT_DO_CLEAR} -eq 1 ]; then
	#
	# Check K2HDKC Slave security group in OpenStack
	#
	SECURITY_GROUP_TMP=`openstack security group list | grep ${SLAVE_SECURITY_GROUP_NAME}`
	if [ ! -z "${SECURITY_GROUP_TMP}" ]; then
		echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Already has \"${SLAVE_SECURITY_GROUP_NAME}\" security group, then remove it." 1>&2
		#
		# Check security group ids for k2hdkc-slave-sec
		#
		SECURITY_GROUP_IDS=`openstack security group list | grep ${SLAVE_SECURITY_GROUP_NAME} | tr -d '|' | awk '{print $1}'`
		for _one_group_id in ${SECURITY_GROUP_IDS}; do
			#
			# Remove all rules in security group
			#
			SECURITY_RULES_IN_GROUP_ID=`openstack security group rule list -f value -c ID ${_one_group_id}`
			for _one_rule_id in ${SECURITY_RULES_IN_GROUP_ID}; do
				echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Remove rule(${_one_rule_id}) in \"${SLAVE_SECURITY_GROUP_NAME}\" security group." 1>&2
				openstack security group rule delete ${_one_rule_id}
			done

			echo "${CREV}[INFO]${CDEF} `${CURRENT_TIME}` Remove security group is(${_one_group_id}) in \"${SLAVE_SECURITY_GROUP_NAME}\"." 1>&2
			openstack security group delete ${_one_group_id}
		done
	fi
fi

#
# Create Security Group for test K2HDKC slave node
#
SECURITY_GROUP_TMP=`openstack security group list | grep ${SLAVE_SECURITY_GROUP_NAME}`
if [ ! -z "${SECURITY_GROUP_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already has \"${SLAVE_SECURITY_GROUP_NAME}\" security group for ${OS_USERNAME}.${CDEF}" 1>&2
	exit 1
fi

openstack security group create --description 'security group for k2hr3 slave node' ${SLAVE_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${SLAVE_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 8031:8031 --protocol tcp --description 'k2hdkc/chmpx slave node control port' ${SLAVE_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add control port(8031) for k2hdkc/chmpx slave node to \"${SLAVE_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 22:22 --protocol tcp --description 'ssh port' ${SLAVE_SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add ssh port(22) for k2hdkc slave node to \"${SLAVE_SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

#----------------------------------------------------------
# Messages
#----------------------------------------------------------
echo ""
echo "${CGRN}${CREV}[SUCCESS]${CDEF}${CGRN} `${CURRENT_TIME}` Finished ${PROGRAM_NAME} process without error.${CDEF}" 1>&2
echo " Base host(openstack trove)  : ${PARENT_HOSTNAME}"
echo " K2HR3 System(instance name) : ${K2HR3_HOSTNAME}"
echo "       APP local port        : 80"
echo "       API local port        : 18080"
echo " K2HR3 Web appliction        : http://${K2HR3_EXTERNAL_HOSTNAME}:28080/"
echo ""

exit 0

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: noexpandtab sw=4 ts=4 fdm=marker
# vim<600: noexpandtab sw=4 ts=4
#
