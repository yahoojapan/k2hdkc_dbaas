#!/bin/bash

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
# plugin for k2hdkc dbaas
#
# interface
# source $PATH/TO/plugin.sh <mode> [phase]
#
# mode:		stack, unstack, clean
# phase:	pre-install, install, post-config, extra, test-config

# plugin.sh - DevStack plugin.sh dispatch script template

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set +o xtrace

TROVE_PATCH_SRCDIR=$DEST/k2hdkc_dbaas/devstack

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

function k2hdkc_install_dir {
    SRC_DIR=$1
    DEST_DIR=$2
    DEST_BASE_DIR=$(dirname ${DEST_DIR})
    if test -d "${DEST_BASE_DIR}"; then
        echo "install -o stack -d ${DEST_DIR}"
        install -o stack -d ${DEST_DIR}
        echo "install -C -D -m 0444 -o stack -v ${SRCDIR}/* ${DEST_DIR}"
        install -C -D -m 0444 -o stack -v ${SRC_DIR}/* ${DEST_DIR}
    else
        echo "NO ${DEST_BASE_DIR}"
        exit 1
    fi
}

echo_summary "start k2hdkc dbaas plugin"

function install_k2hdkc_dbaas {
    echo "install_k2hdkc_dbaas"

    echo "Trove API for k2hdkc"
    # 1. DEST/trove/trove/common/cfg.py
    k2hdkc_patch_file "$DEST/trove/trove/common/cfg.py" "${TROVE_PATCH_SRCDIR}/patches/trove-common-cfg.py"

    # 2. $DEST/trove/trove/common/strategies/cluster/experimental/k2hdkc
    k2hdkc_install_dir ${TROVE_PATCH_SRCDIR}/common/strategies/cluster/experimental/k2hdkc $DEST/trove/trove/common/strategies/cluster/experimental/k2hdkc 

    echo "Trove TaskManager for k2hdkc"
    # 3. opt/stack/trove/trove/templates/k2hdkc/config.template
    k2hdkc_install_dir ${TROVE_PATCH_SRCDIR}/templates/k2hdkc $DEST/trove/trove/templates/k2hdkc

    # 4. /trove/common/configurations.py
    k2hdkc_patch_file $DEST/trove/trove/common/configurations.py ${TROVE_PATCH_SRCDIR}/patches/trove-common-configurations.py

    # 5. /trove/common/template.py
    k2hdkc_patch_file $DEST/trove/trove/common/template.py ${TROVE_PATCH_SRCDIR}/patches/trove-common-template.py

    # 6. trove-db-sqlalchemy-migrate_repo-versions-020_configurations.py 
    k2hdkc_patch_file $DEST/trove/trove/db/sqlalchemy/migrate_repo/versions/020_configurations.py ${TROVE_PATCH_SRCDIR}/patches/trove-db-sqlalchemy-migrate_repo-versions-020_configurations.py

    # 7. trove_dashboard/api/trove.py
    k2hdkc_patch_file $DEST/trove-dashboard/trove_dashboard/api/trove.py ${TROVE_PATCH_SRCDIR}/patches/trove_dashboard-api-trove.py

    # 8. trove_dashboard/api/trove.py
    k2hdkc_patch_file $DEST/trove-dashboard/trove_dashboard/content/databases/db_capability.py ${TROVE_PATCH_SRCDIR}/patches/trove_dashboard-content-databases-db_capability.py

    # 9. trove_dashboard-content-database_clusters-forms.py
    k2hdkc_patch_file $DEST/trove-dashboard/trove_dashboard/content/database_clusters/forms.py ${TROVE_PATCH_SRCDIR}/patches/trove_dashboard-content-database_clusters-forms.py

    # 10. trove_dashboard-enabled-_1740_project_database_clusters_panel.py
    k2hdkc_patch_file $DEST/trove-dashboard/trove_dashboard/enabled/_1740_project_database_clusters_panel.py ${TROVE_PATCH_SRCDIR}/patches/trove_dashboard-enabled-_1740_project_database_clusters_panel.py
}

function create_k2hdkc_dbaas_guest_image {
    echo "create_k2hdkc_dbaas_guest_image"
    if ! test -d "$DEST/trove/integration/scripts/files/elements/guest-agent-k2hdkc"; then
        cp -r $DEST/trove/integration/scripts/files/elements/guest-agent $DEST/trove/integration/scripts/files/elements/guest-agent-k2hdkc
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/guest-agent-k2hdkc/post-install.d/99-clean-apt ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-guest-agent-99-clean-apt.patch
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/guest-agent-k2hdkc/package-installs.yaml ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-guest-agent-package-installs.yaml.patch
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/guest-agent-k2hdkc/install.d/50-user ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-guest-agent-50-user.patch
    else
        echo "NO $DEST/trove/integration/scripts/files/elements/guest-agent-k2hdkc alread exists. Run unstack.sh firstly."
        exit 1
    fi
    # 2. copy the ubuntu-guest element
    if ! test -d "$DEST/trove/integration/scripts/files/elements/centos-8-guest"; then
        cp -r $DEST/trove/integration/scripts/files/elements/ubuntu-guest $DEST/trove/integration/scripts/files/elements/centos-8-guest
        # 2.1. move files
        mv -f $DEST/trove/integration/scripts/files/elements/centos-8-guest/environment.d/99-reliable-apt-key-importing.bash \
              $DEST/trove/integration/scripts/files/elements/centos-8-guest/environment.d/99-reliable-apt-key-importing.bash.orig
        mv -f $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/15-trove-dep \
              $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/15-trove-dep.orig
        mv -f $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/50-user \
              $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/50-user.orig
        # 2.2. patch files
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/05-base-apps ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-centos-8-guest-05-base-apps.patch
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/98-ssh ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-centos-8-guest-98-ssh.patch
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/centos-8-guest/install.d/99-clean-apt ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-centos-8-guest-99-clean-apt.patch
        k2hdkc_patch_file $DEST/trove/integration/scripts/files/elements/centos-8-guest/pre-install.d/04-baseline-tools ${TROVE_PATCH_SRCDIR}/patches/trove-integration-scripts-files-elements-centos-8-guest-04-baseline-tools.patch
    else
        echo "NO $DEST/trove/integration/scripts/files/elements/centos-8-guest. Run unstack.sh firstly."
        exit 1
    fi
    $DEST/k2hdkc_dbaas/utils/disk-image-create.sh
    IMAGE_FILE=$DEST/images/trove-datastore-centos-8-k2hdkc.qcow2
    IMAGE_NAME="trove-datastore-centos-8-k2hdkc"
    if [ ! -f ${IMAGE_FILE} ]; then
        echo "NO Image file found at ${IMAGE_FILE}"
        exit 1
    fi
    TROVE_DATASTORE_TYPE_K2HDKC=k2hdkc
    TROVE_DATASTORE_VERSION_K2HDKC=0.9.30

    echo "Add the image to glance"
    glance_image_id=$(openstack --os-region-name RegionOne --os-password ${SERVICE_PASSWORD} \
      --os-project-name service --os-username trove \
      image create ${IMAGE_NAME} \
      --disk-format qcow2 --container-format bare --property hw_rng_model='virtio' --file ${IMAGE_FILE} \
      -c id -f value)

    echo "Register the image in datastore"
    $TROVE_MANAGE datastore_update $TROVE_DATASTORE_TYPE_K2HDKC ""
    $TROVE_MANAGE datastore_version_update $TROVE_DATASTORE_TYPE_K2HDKC $TROVE_DATASTORE_VERSION_K2HDKC $TROVE_DATASTORE_TYPE_K2HDKC $glance_image_id "" 1
    $TROVE_MANAGE datastore_update $TROVE_DATASTORE_TYPE_K2HDKC $TROVE_DATASTORE_VERSION_K2HDKC

    echo "Add parameter validation rules if available"
    if [ -f $DEST/trove/trove/templates/$TROVE_DATASTORE_TYPE_K2HDKC/validation-rules.json ]; then
        $TROVE_MANAGE db_load_datastore_config_parameters "$TROVE_DATASTORE_TYPE_K2HDKC" "$TROVE_DATASTORE_VERSION_K2HDKC" \
            $DEST/trove/trove/templates/$TROVE_DATASTORE_TYPE_K2HDKC/validation-rules.json
    else
        echo "NO $DEST/trove/trove/templates/$TROVE_DATASTORE_TYPE_K2HDKC/validation-rules.json"
        exit 1
    fi

}

function configure_k2hdkc_dbaas {
    echo "configure_k2hdkc_dbaas"

    # 1. /etc/trove/trove.conf
    k2hdkc_patch_file /etc/trove/trove.conf ${TROVE_PATCH_SRCDIR}/patches/etc-trove-trove.conf

    # 2. /etc/trove/trove-guestagent.conf
    if test -f "/etc/trove/trove-guestagent.conf"; then
        if test -f "$DEST/trove/integration/scripts/functions"; then
            iniset $TROVE_GUESTAGENT_CONF DEFAULT backup_swift_container k2hdkc_backups
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_use_gzip_compression True
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_use_openssl_encryption True
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_aes_cbc_key "default_aes_cbc_key"
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_use_snet False
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_chunk_size 65536
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_segment_max_size 2147483648
            iniset $TROVE_GUESTAGENT_CONF service_credentials backup_use_gzip_compression True
        else
            echo "NO $DEST/trove/integration/scripts/functions"
            exit 1
        fi
    else
        echo "NO /etc/trove/trove.conf"
        exit 1
    fi
}

function configure_horizonf_for_k2hr3 {
    echo "configure_horizonf_for_k2hr3"

    echo "changes local_settings.py for k2hr3"
    LOCAL_SETTINGS_PY="/opt/stack/horizon/openstack_dashboard/local/local_settings.py"
    # 1. local_settings.py
    if test -f "${LOCAL_SETTINGS_PY}"; then
        if test -n "${KEYSTONE_SERVICE_HOST}" ; then
            cat > local_settings_for_k2hr3 <<EOF
HORIZON_CONFIG["k2hr3"] = {
    "http_scheme": "http",
    "host": "${KEYSTONE_SERVICE_HOST}",
    "port": 18080,
}            
HORIZON_CONFIG["k2hr3_from_private_network"] = {
    "http_scheme": "http",
    "host": "${KEYSTONE_SERVICE_HOST}",
    "port": 18080,
}            
EOF
            cat ./local_settings_for_k2hr3 >> ${LOCAL_SETTINGS_PY}
            if test -f "local_settings_for_k2hr3"; then
                rm -f "local_settings_for_k2hr3"
            fi
        else
            echo "NO ${KEYSTONE_SERVICE_HOST}"
            exit 1
        fi
    else
        echo "NO ${LOCAL_SETTINGS_PY}"
        exit 1
    fi
}


# check for service enabled
if is_service_enabled k2hdkc-dbaas; then

    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        # Set up system services
        echo_summary "Configuring system services K2hdkc"

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        # Perform installation of service source
        echo_summary "Installing k2hdkc_dbaas"
        install_k2hdkc_dbaas

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        echo_summary "Configuring K2hdkc"
        configure_k2hdkc_dbaas
        echo_summary "Configuring Horizon for k2hr3"
        configure_horizonf_for_k2hr3
        echo_summary "Installing a python k2hr3 library for trove-dashboard"
        $DEST/k2hdkc_dbaas/utils/install_python-k2hr3client.sh

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        # Initialize and start the template service
        echo_summary "Initializing K2hdkc"
        # 1. create k2hdkc guest image
        create_k2hdkc_dbaas_guest_image
    fi

    if [[ "$1" == "unstack" ]]; then
        # Shut down template services
        # no-op
        cd $DEST/trove && git checkout -- .
        cd $DEST/trove-dashboard && git checkout -- .
        if test -d "$DEST/trove/common/strategies/cluster/experimental/k2hdkc"; then
            echo "rm -rf $DEST/trove/common/strategies/cluster/experimental/k2hdkc"
            rm -rf $DEST/trove/common/strategies/cluster/experimental/k2hdkc
        fi
        if test -d "$DEST/trove/templates/k2hdkc"; then
            echo "rm -rf $DEST/trove/templates/k2hdkc"
            rm -rf $DEST/trove/templates/k2hdkc
        fi
        if test -d "$DEST/integration/scripts/files/elements/centos-8-guest"; then
            echo "rm -rf $DEST/integration/scripts/files/elements/centos-8-guest"
            rm -rf $DEST/integration/scripts/files/elements/centos-8-guest
        fi
        if test -d "$DEST/integration/scripts/files/elements/guest-agent-k2hdkc"; then
            echo "rm -rf $DEST/integration/scripts/files/elements/guest-agent-k2hdkc"
            rm -rf $DEST/integration/scripts/files/elements/guest-agent-k2hdkc
        fi

    fi

    if [[ "$1" == "clean" ]]; then
        # Remove state and transient data
        # Remember clean.sh first calls unstack.sh
        # no-op
        :
    fi
else
    echo "NO is_service_enabled"
fi

echo_summary "end k2hdkc dbaas plugin"

# Restore xtrace
$XTRACE

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
