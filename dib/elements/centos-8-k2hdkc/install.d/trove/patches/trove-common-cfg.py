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

diff --git a/trove/common/cfg.py b/trove/common/cfg.py
index a97623f6..4793725d 100644
--- a/trove/common/cfg.py
+++ b/trove/common/cfg.py
@@ -370,7 +370,8 @@ common_opts = [
                          'couchdb': 'f0a9ab7b-66f7-4352-93d7-071521d44c7c',
                          'vertica': 'a8d805ae-a3b2-c4fd-gb23-b62cee5201ae',
                          'db2': 'e040cd37-263d-4869-aaa6-c62aa97523b5',
-                         'mariadb': '7a4f82cc-10d2-4bc6-aadc-d9aacc2a3cb5'},
+                         'mariadb': '7a4f82cc-10d2-4bc6-aadc-d9aacc2a3cb5',
+                         'k2hdkc': '07e220a2-a8c6-4061-b9a6-a654b2f5fc2e'},
                 help='Unique ID to tag notification events.'),
     cfg.StrOpt('network_label_regex', default='^private$',
                help='Regular expression to match Trove network labels.'),
@@ -1515,11 +1516,98 @@ mariadb_opts = [
                'galera_common.guestagent.GaleraCommonGuestAgentStrategy',
                help='Class that implements datastore-specific Guest Agent API '
                     'logic.'),
+    cfg.IntOpt('default_password_length',
+               default='${mysql.default_password_length}',
+               help='Character length of generted passwords.',
+               deprecated_name='default_password_length',
+               deprecated_group='DEFAULT'),
+]
+
+# K2hdkc
+k2hdkc_group = cfg.OptGroup(
+    'k2hdkc', title='K2HDKC options',
+    help="Oslo option group designed for K2hdkc datastore")
+k2hdkc_opts = [
+    cfg.BoolOpt('icmp', default=False,
+                help='Whether to permit ICMP.',
+                deprecated_for_removal=True),
+    cfg.ListOpt('tcp_ports', default=["8020", "8021", "8031"],
+                item_type=ListOfPortsType,
+                help='List of TCP ports and/or port ranges to open '
+                     'in the security group (only applicable '
+                     'if trove_security_groups_support is True).'),
+    cfg.ListOpt('udp_ports', default=[], item_type=ListOfPortsType,
+                help='List of UDP ports and/or port ranges to open '
+                     'in the security group (only applicable '
+                     'if trove_security_groups_support is True).'),
+    cfg.StrOpt('mount_point', default='/var/lib/k2hdkc',
+               help="Filesystem path for mounting "
+                    "volumes if volume support is enabled."),
+    cfg.BoolOpt('root_on_create', default=False,
+                help='Enable the automatic creation of the root user for the '
+                'service during instance-create. The generated password for '
+                'the root user is immediately returned in the response of '
+                "instance-create as the 'password' field."),
+    cfg.IntOpt('ctrl_port', default=8021,
+               help='Control Port to connet with chmpx process.'),
+    cfg.IntOpt('usage_timeout', default=400,
+               help='Maximum time (in seconds) to wait for a Guest to become '
+                    'active.'),
+    cfg.BoolOpt('volume_support', default=True,
+                help='Whether to provision a Cinder volume for datadir.'),
+    cfg.StrOpt('device_path', default='/dev/vdb',
+               help='Device path for volume if volume support is enabled.'),
+    cfg.StrOpt('root_controller',
+               default='trove.extensions.common.service.DefaultRootController',
+               help='Root controller implementation for k2hdkc.'),
+    cfg.ListOpt('ignore_users', default=['os_admin', 'root'],
+                help='Users to exclude when listing users.',
+                deprecated_name='ignore_users',
+                deprecated_group='DEFAULT'),
+    cfg.StrOpt('api_strategy',
+               default='trove.common.strategies.cluster.experimental.k2hdkc.api.K2hdkcAPIStrategy',
+               help='Class that implements datastore-specific API logic.'),
+    cfg.StrOpt('taskmanager_strategy',
+               default='trove.common.strategies.cluster.experimental.k2hdkc.taskmanager.K2hdkcTaskManagerStrategy',
+               help='Class that implements datastore-specific task manager logic.'),
+    cfg.StrOpt('guestagent_strategy',
+               default='trove.common.strategies.cluster.experimental.k2hdkc.guestagent.K2hdkcGuestAgentStrategy',
+               help='Class that implements datastore-specific Guest Agent API logic.'),
+    cfg.BoolOpt('cluster_support', default=True,
+                help='Enable clusters to be created and managed.'),
+    cfg.IntOpt('min_cluster_member_count', default=3,
+               help='Minimum number of members in K2hdkc cluster.'),
     cfg.IntOpt('default_password_length',
                default='${mysql.default_password_length}',
                help='Character length of generated passwords.',
                deprecated_name='default_password_length',
                deprecated_group='DEFAULT'),
+    cfg.StrOpt('backup_strategy', default='K2hdkcArchive',
+               help='Default strategy to perform backups.',
+               deprecated_name='backup_strategy',
+               deprecated_group='DEFAULT'),
+    cfg.DictOpt('backup_incremental_strategy', default={},
+                help='Incremental Backup Runner based on the default '
+                'strategy. For strategies that do not implement an '
+                'incremental, the runner will use the default full backup.',
+                deprecated_name='backup_incremental_strategy',
+                deprecated_group='DEFAULT'),
+    cfg.StrOpt('backup_namespace',
+               default="trove.guestagent.strategies.backup.experimental."
+                       "k2hdkc_impl",
+               help='Namespace to load backup strategies from.',
+               deprecated_name='backup_namespace',
+               deprecated_group='DEFAULT'),
+    cfg.StrOpt('restore_namespace',
+               default='trove.guestagent.strategies.restore.experimental.'
+                       'k2hdkc_impl',
+               help='Namespace to load restore strategies from.',
+               deprecated_name='restore_namespace',
+               deprecated_group='DEFAULT'),
+    cfg.StrOpt('replication_strategy', default=None,
+               help='Default strategy for replication.'),
+    cfg.StrOpt('replication_namespace', default=None,
+               help='Namespace to load replication strategies from.'),
 ]
 
 # RPC version groups
@@ -1615,6 +1703,7 @@ CONF.register_group(couchdb_group)
 CONF.register_group(vertica_group)
 CONF.register_group(db2_group)
 CONF.register_group(mariadb_group)
+CONF.register_group(k2hdkc_group)
 CONF.register_group(network_group)
 CONF.register_group(service_credentials_group)
 
@@ -1630,6 +1719,7 @@ CONF.register_opts(couchdb_opts, couchdb_group)
 CONF.register_opts(vertica_opts, vertica_group)
 CONF.register_opts(db2_opts, db2_group)
 CONF.register_opts(mariadb_opts, mariadb_group)
+CONF.register_opts(k2hdkc_opts, k2hdkc_group)
 CONF.register_opts(network_opts, network_group)
 CONF.register_opts(service_credentials_opts, service_credentials_group)
 
