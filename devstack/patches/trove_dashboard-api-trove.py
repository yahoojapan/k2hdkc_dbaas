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

diff --git a/trove_dashboard/api/trove.py b/trove_dashboard/api/trove.py
index 83208de..2201a92 100644
--- a/trove_dashboard/api/trove.py
+++ b/trove_dashboard/api/trove.py
@@ -25,6 +25,16 @@ from keystoneauth1 import loading
 from keystoneauth1 import session
 from novaclient import client as nova_client
 
+import json
+import re
+from pathlib import Path
+
+from k2hr3client.http import K2hr3Http
+from k2hr3client.policy import K2hr3Policy
+from k2hr3client.resource import K2hr3Resource
+from k2hr3client.role import K2hr3Role
+from k2hr3client.token import K2hr3Token, K2hr3RoleToken, K2hr3RoleTokenList
+
 # Supported compute versions
 NOVA_VERSIONS = base.APIVersionManager("compute", preferred_version=2)
 NOVA_VERSIONS.load_supported_version(1.1,
@@ -67,7 +77,8 @@ def cluster_delete(request, cluster_id):
 
 def cluster_create(request, name, volume, flavor, num_instances,
                    datastore, datastore_version,
-                   nics=None, root_password=None, locality=None):
+                   nics=None, root_password=None, locality=None,
+                   configuration=None):
     instances = []
     for i in range(num_instances):
         instance = {}
@@ -84,7 +95,8 @@ def cluster_create(request, name, volume, flavor, num_instances,
         datastore,
         datastore_version,
         instances=instances,
-        locality=locality)
+        locality=locality,
+        configuration=configuration)
 
 
 def cluster_grow(request, cluster_id, new_instances):
@@ -414,9 +426,207 @@ def configuration_instances(request, group_id):
     return troveclient(request).configurations.instances(group_id)
 
 
-def configuration_update(request, group_id, values):
-    return troveclient(request).configurations.update(group_id, values)
+def _get_extdata_url(request, values, k2hr3_url):
+    try:
+        k2hr3_token = K2hr3Token(request.user.project_name, request.user.token.id)
+        http = K2hr3Http(k2hr3_url)
+        http.POST(k2hr3_token)
+        server_role_name = "/".join([values["cluster-name"],"server"])
+        k2hr3_role_token = K2hr3RoleToken(
+            k2hr3_token.token,
+            role=server_role_name,
+            expire=0
+        )
+        http.GET(k2hr3_role_token)
+        roletoken = k2hr3_role_token.token
+        if roletoken:
+            LOG.debug("roletoken {}".format(roletoken))
+            k2hr3_role_token_list = K2hr3RoleTokenList(
+                k2hr3_token.token,
+                role=server_role_name,
+                expand=True
+            )
+            http.GET(k2hr3_role_token_list)
+            registerpath = k2hr3_role_token_list.registerpath(roletoken)
+            if registerpath:
+                LOG.debug("registerpath {}".format(registerpath))
+                extdata_url = "{}/extdata/trove/{}".format(k2hr3_url, registerpath)
+                LOG.debug(extdata_url)
+                return extdata_url
+            else:
+                raise Exception("no registerpath")
+        else:
+            raise Exception("no roletoken")
+    except Exception as e:
+        error_msg = 'create_k2hr3_role error {}'.format(e)
+        LOG.error(error_msg)
+        raise Exception(error_msg)
+
+def _create_k2hr3_role(request, values, k2hr3_url):
+    try:
+        k2hr3_token = K2hr3Token(request.user.project_name, request.user.token.id)
+        http = K2hr3Http(k2hr3_url)
+        http.POST(k2hr3_token)
+        policy_name="yrn:yahoo:::{}:policy:{}".format(request.user.project_name, values["cluster-name"])
+        k2hr3_role = K2hr3Role(
+            k2hr3_token.token,
+            name=values["cluster-name"],
+            policies=[policy_name],
+            alias=[]
+        )
+        http.POST(k2hr3_role)
+        server_role = K2hr3Role(
+            k2hr3_token.token,
+            name="/".join([values["cluster-name"],"server"]),
+            policies=[],
+            alias=[]
+        )
+        http.POST(server_role)
+        slave_role = K2hr3Role(
+            k2hr3_token.token,
+            name="/".join([values["cluster-name"],"slave"]),
+            policies=[],
+            alias=[]
+        )
+        http.POST(slave_role)
+    except Exception as e:
+        error_msg = 'create_k2hr3_role error {}'.format(e)
+        LOG.error(error_msg)
+        raise Exception(error_msg)
+
+
+def _create_k2hr3_policy(request, values, k2hr3_url):
+    try:
+        k2hr3_token = K2hr3Token(request.user.project_name, request.user.token.id)
+        http = K2hr3Http(k2hr3_url)
+        http.POST(k2hr3_token)
+        server_resource="yrn:yahoo:::{}:resource:{}/server".format(request.user.project_name, values["cluster-name"])
+        slave_resource="yrn:yahoo:::{}:resource:{}/slave".format(request.user.project_name, values["cluster-name"])
+        k2hr3_policy = K2hr3Policy(
+            k2hr3_token.token,
+            name=values["cluster-name"],
+            effect='allow',
+            action=['yrn:yahoo::::action:read'],
+            resource=[server_resource, slave_resource],
+            condition=None,
+            alias=[]
+        )
+        http.POST(k2hr3_policy)
+    except Exception as e:
+        error_msg = 'create_k2hr3_policy error {}'.format(e)
+        LOG.error(error_msg)
+        raise Exception(error_msg)
+
+
+def _create_k2hr3_resource(request, values, k2hr3_url):
+    try:
+        k2hr3_token = K2hr3Token(request.user.project_name, request.user.token.id)
+        http = K2hr3Http(k2hr3_url)
+        http.POST(k2hr3_token)
+        k2hr3_resource = K2hr3Resource(
+            k2hr3_token.token,
+            name=values["cluster-name"],
+            data_type='string',
+            data=Path('/opt/stack/k2hdkc_dbaas/utils/python-k2hr3client/examples/example_resource.txt'),
+            keys={
+                "cluster-name": values["cluster-name"],
+                "chmpx-server-port": values["chmpx-server-port"],
+                "chmpx-server-ctlport": values["chmpx-server-ctlport"],
+                "chmpx-slave-ctlport": values["chmpx-slave-ctlport"]
+            },
+            alias=[]
+        )
+        http.POST(k2hr3_resource)
+        k2hr3_resource_server = K2hr3Resource(
+            k2hr3_token.token,
+            name="/".join([values["cluster-name"],"server"]),
+            data_type='string',
+            data="",
+            keys={
+                "chmpx-mode": "SERVER"
+            },
+            alias=[]
+        )
+        http.POST(k2hr3_resource_server)
+        k2hr3_resource_slave = K2hr3Resource(
+            k2hr3_token.token,
+            name="/".join([values["cluster-name"],"slave"]),
+            data_type='string',
+            data="",
+            keys={
+                "chmpx-mode": "SLAVE"
+            },
+            alias=[]
+        )
+        http.POST(k2hr3_resource_slave)
+    except Exception as e:
+        error_msg = 'create_k2hr3_resource error {}'.format(e)
+        LOG.error(error_msg)
+        raise Exception(error_msg)
 
+def configuration_update(request, group_id, values):
+    try:
+        LOG.debug("before values={} request.user.token.id={} request.user={} request.user.project_name={}".format(values, request.user.token.id, request.user, request.user.project_name))
+        python_values = json.loads(values)
+        # Applies default values
+        if not 'chmpx-server-ctlport' in python_values:
+            python_values["chmpx-server-ctlport"] = 8021
+        if not 'chmpx-slave-ctlport' in python_values:
+            python_values["chmpx-slave-ctlport"] = 8031
+        if not 'chmpx-server-port' in python_values:
+            python_values["chmpx-server-port"] = 8020
+        if not 'cluster-name' in python_values:
+            python_values["cluster-name"] = "k2hdkccluster"
+
+        # Creates k2hr3 resources
+        # Gets k2hr3_url
+        horizon_config = getattr(settings, 'HORIZON_CONFIG', False)
+        if horizon_config is False:
+            raise Exception("HORIZON_CONFIG should exist in local_settings.py")
+        if not 'k2hr3' in horizon_config:
+            raise Exception("k2hr3 should exist in HORIZON_CONFIG of local_settings.py")
+        if not 'http_scheme' in horizon_config['k2hr3']:
+            raise Exception("http_scheme should exist in HORIZON_CONFIG['k2hr3'] of local_settings.py")
+        k2hr3_http_scheme = horizon_config['k2hr3']['http_scheme']
+        if not 'host' in horizon_config['k2hr3']:
+            raise Exception("host should exist in HORIZON_CONFIG['k2hr3'] of local_settings.py")
+        k2hr3_host = horizon_config['k2hr3']['host']
+        if not 'port' in horizon_config['k2hr3']:
+            raise Exception("port should exist in HORIZON_CONFIG['k2hr3'] of local_settings.py")
+        k2hr3_port = horizon_config['k2hr3']['port']
+        k2hr3_url = "{}://{}:{}/v1".format(k2hr3_http_scheme, k2hr3_host, k2hr3_port)
+        _create_k2hr3_resource(request, python_values, k2hr3_url)
+
+        # Creates k2hr3 policies
+        _create_k2hr3_policy(request, python_values, k2hr3_url)
+
+        # Creates k2hr3 roles
+        _create_k2hr3_role(request, python_values, k2hr3_url)
+
+        # Creates k2hr3 roletoken
+        # Gets k2hr3_url_from_private_network
+        if not 'k2hr3_from_private_network' in horizon_config:
+            raise Exception("k2hr3_from_private_network should exist in HORIZON_CONFIG of local_settings.py")
+        if not 'http_scheme' in horizon_config['k2hr3_from_private_network']:
+            raise Exception("http_scheme should exist in HORIZON_CONFIG['k2hr3_from_private_network'] of local_settings.py")
+        k2hr3_http_scheme_from_private_network = horizon_config['k2hr3_from_private_network']['http_scheme']
+        if not 'host' in horizon_config['k2hr3_from_private_network']:
+            raise Exception("host should exist in HORIZON_CONFIG['k2hr3_from_private_network'] of local_settings.py")
+        k2hr3_host_from_private_network = horizon_config['k2hr3_from_private_network']['host']
+        if not 'port' in horizon_config['k2hr3_from_private_network']:
+            raise Exception("port should exist in HORIZON_CONFIG['k2hr3_from_private_network'] of local_settings.py")
+        k2hr3_port_from_private_network = horizon_config['k2hr3_from_private_network']['port']
+        k2hr3_url_from_private_network = "{}://{}:{}/v1".format(
+                k2hr3_http_scheme_from_private_network,
+                k2hr3_host_from_private_network,
+                k2hr3_port_from_private_network)
+        extdata_url = _get_extdata_url(request, python_values, k2hr3_url_from_private_network)
+
+        python_values["extdata-url"] = extdata_url
+        return troveclient(request).configurations.update(group_id, json.dumps(python_values))
+    except Exception as e:
+        LOG.error('error {}'.format(e))
+    return False
 
 def configuration_default(request, instance_id):
     return troveclient(request).instances.configuration(instance_id)
