#!/bin/sh
#
# K2HR3 PACK for K2HDKC DBaaS based on Trove
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

#
# Get Parent host inforamtion
#
PARENT_HOSTNAME=`hostname`
if [ -z "${PARENT_HOSTNAME}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get local hostname.${CDEF}" 1>&2
	exit 1
fi

which dig >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Not found dig command, you need to install dig command(ex. bind-utils on centos).${CDEF}" 1>&2
    exit 1
fi

PARENT_IP=`dig ${PARENT_HOSTNAME} | grep ${PARENT_HOSTNAME} | grep -v '^;' | sed -e 's/IN A//g' | awk '{print $3}'`
if [ -z "${PARENT_IP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get IP address for localhost.${CDEF}" 1>&2
	exit 1
fi

echo "* Confirmation of hostname or IP address to access K2HR3 Web Application"
echo "  To access the K2HR3 Web Application in a browser,"
echo "  if ${CGRN}${PARENT_HOSTNAME}${CDEF} is accessible, type yes(y) or enter key to proceed."
echo "  if specify hostname or IP address instead of ${CGRN}${PARENT_HOSTNAME}${CDEF}, input it."
echo ""
echo -n "input(null/yes/hostname/ip): " 1>&2
read INPUT_PARENT_HOSTNAME

if [ "X${INPUT_PARENT_HOSTNAME}" = "Xyes" -o "X${INPUT_PARENT_HOSTNAME}" = "XYES" -o "X${INPUT_PARENT_HOSTNAME}" = "Xy" -o "X${INPUT_PARENT_HOSTNAME}" = "XY" -o "X${INPUT_PARENT_HOSTNAME}" = "X" ]; then
	K2HR3_EXTERNAL_HOSTNAME=${PARENT_HOSTNAME}
else
	#
	# Change parent hostname
	#
	K2HR3_EXTERNAL_HOSTNAME=${INPUT_PARENT_HOSTNAME}
fi
echo ""

#
# Check k2hr3_pack directory
#
K2HR3_PACK_NAME="k2hr3_pack"
K2HDKC_DBAAS_UTIL_DIR="${CURRENT_DIR}/k2hdkc_dbaas/utils"
K2HR3_PACK_DIR="${K2HDKC_DBAAS_UTIL_DIR}/${K2HR3_PACK_NAME}"
if [ ! -d ${K2HR3_PACK_DIR} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not find ${K2HR3_PACK_DIR} directory.${CDEF}" 1>&2
	exit 1
fi

#
# Set OpenStack Environments
#
# [NOTE]
# This script uses "trove" user and "service" project.
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Setup environments for trove user to build K2HR3 system.${CDEF}" 1>&2

PROJECT_NAME="service"
export OS_AUTH_URL="http://${PARENT_IP}/identity"
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
		echo -n "* Please input \"trove\" user passphrase(no input is displayed) : "
		read -sr OS_PASSWORD_INPUT
		echo ""
		OS_PASSWORD=${OS_PASSWORD_INPUT}
	else
		echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} Found ${LOCAL_CONF_FILE} file and it has ADMIN_PASSWORD value, so use it for trove user passphrase.${CDEF}" 1>&2
	fi
else
	echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} OS_PASSWORD environment is set, use it for trove user passphrase.${CDEF}" 1>&2
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

KEYPAIR_NAME="k2hr3key"
PRIVATE_KEY_PATH="${K2HR3_PACK_DIR}/conf"
PRIVATE_KEY_FILE="${PRIVATE_KEY_PATH}/${KEYPAIR_NAME}_private.pem"
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

SECURITY_GROUP_NAME="k2hdkc-dbaas-k2hr3-secgroup"

SECURITY_GROUP_TMP=`openstack security group list | grep ${SECURITY_GROUP_NAME}`
if [ ! -z "${SECURITY_GROUP_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already has \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group create --description 'security group for k2hr3 system' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 22:22 --protocol tcp --description 'ssh port' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add ssh port(22) to \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 80:80 --protocol tcp --description 'k2hr3 app http port' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add k2hr3 app http port(80) to \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 18080:18080 --protocol tcp --description 'k2hr3 api http port' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add k2hr3 api http port(18080) to \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
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

K2HR_HOST_TMP=`openstack server list | grep ${K2HR3_HOSTNAME}`
if [ ! -z ${K2HR_HOST_TMP} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already run \"${K2HR3_HOSTNAME}\" instance.${CDEF}" 1>&2
	exit 1
fi

openstack server create --flavor ${FLAVOR_ID} --image ${IMAGE_ID} --key-name ${KEYPAIR_NAME} --user-data ${USERDATA_FILE} --security-group ${SECURITY_GROUP_NAME} --network ${NETWORK_ID} ${K2HR3_HOSTNAME}
rm -f ${USERDATA_FILE}

#
# Wait for instance up
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Wait 300 sec for instance(k2hdkc-dbaas-k2hr3) up.${CDEF}" 1>&2
sleep 300

#
# Get Server ID and IP Address
#
K2HR3_SERVER_ID=`openstack server list -f value | grep ${K2HR3_HOSTNAME} | grep ACTIVE | awk '{print $1}'`
if [ -z ${K2HR3_SERVER_ID} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${K2HR3_HOSTNAME}\" instance.${CDEF}" 1>&2
	exit 1
fi

K2HR3_IP_ADDRESS=`openstack server show ${K2HR3_SERVER_ID} -f value | grep 'private=' | sed -e 's/private=//g'`
if [ -z ${K2HR3_IP_ADDRESS} ]; then
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
# Make k2hr3_pack archive file
#
K2HR3_PACK_TGZ="${K2HR3_PACK_NAME}.tgz"
tar cvf - -C ${K2HDKC_DBAAS_UTIL_DIR} ${K2HR3_PACK_NAME} | gzip - > /tmp/${K2HR3_PACK_TGZ}

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
# Run k2hr3 onepack.sh
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Start to run all K2HR3 system on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2

ssh -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} ${USER_AND_HOST} "${K2HR3_PACK_NAME}/bin/onepack.sh -ni -nc --run_user nobody --openstack_region ${OS_REGION_NAME} --keystone_url http://${PARENT_IP}/identity --app_port 80 --app_port_external 28080 --app_host ${K2HR3_IP_ADDRESS} --app_host_external ${K2HR3_EXTERNAL_HOSTNAME} --api_port 18080 --api_port_external 18080 --api_host ${K2HR3_IP_ADDRESS} --api_host_external ${K2HR3_EXTERNAL_HOSTNAME}"
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Failed to run k2hr3 system on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Succeed to run all K2HR3 system on \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2

#
# Get haproxy example configuration
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Setup haproxy to access K2HR3 system from parent host.${CDEF}" 1>&2

HAPROXY_CFG_FILE="${K2HR3_PACK_DIR}/conf/haproxy.cfg"
HAPROXY_LOG_FILE="${K2HR3_PACK_DIR}/log/haproxy.log"
if [ -f ${HAPROXY_CFG_FILE} ]; then
	rm -f ${HAPROXY_CFG_FILE}
fi
if [ -f ${HAPROXY_LOG_FILE} ]; then
	rm -f ${HAPROXY_LOG_FILE}
fi

scp -o ${SSH_OPTION} -i ${PRIVATE_KEY_FILE} ${USER_AND_HOST}:/home/ubuntu/${K2HR3_PACK_NAME}/conf/haproxy_example.cfg ${HAPROXY_CFG_FILE}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get haproxy configuration file from \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi
if [ ! -f ${HAPROXY_CFG_FILE} ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not get haproxy configuration file from \"${K2HR3_HOSTNAME}\".${CDEF}" 1>&2
	exit 1
fi

#
# Run Haproxy
#
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

#
# Change private IP address to K2HR3
#
echo "${CGRN}${CREV}[INFO]${CDEF}${CGRN} `${CURRENT_TIME}` Restart horizon httpd for changing k2hr3 private IP address.${CDEF}" 1>&2

HORIZON_BASE_DIR="${K2HDKC_DBAAS_UTIL_DIR}/../../horizon"
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

#
# Additional settings for test K2HDKC slave node
#
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
# Create Security Group for test K2HDKC slave node
#
SECURITY_GROUP_NAME="k2hdkc-slave-sec"

SECURITY_GROUP_TMP=`openstack security group list | grep ${SECURITY_GROUP_NAME}`
if [ ! -z "${SECURITY_GROUP_TMP}" ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Already has \"${SECURITY_GROUP_NAME}\" security group for ${OS_USERNAME}.${CDEF}" 1>&2
	exit 1
fi

openstack security group create --description 'security group for k2hr3 slave node' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not create \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 8031:8031 --protocol tcp --description 'k2hdkc/chmpx slave node control port' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add control port(8031) for k2hdkc/chmpx slave node to \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

openstack security group rule create --ingress --ethertype IPv4 --project ${PROJECT_ID} --dst-port 22:22 --protocol tcp --description 'ssh port' ${SECURITY_GROUP_NAME}
if [ $? -ne 0 ]; then
	echo "${CRED}${CREV}[ERROR]${CDEF}${CRED} `${CURRENT_TIME}` Could not add ssh port(22) for k2hdkc slave node to \"${SECURITY_GROUP_NAME}\" security group.${CDEF}" 1>&2
	exit 1
fi

#
# Messages
#
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
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
