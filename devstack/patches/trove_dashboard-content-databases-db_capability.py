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

*** db_capability.py    2020-07-07 14:24:35.181997910 +0900
--- db_capability.py.new        2020-07-07 14:24:12.208540068 +0900
***************
*** 21,32 ****
  PERCONA_CLUSTER = "pxc"
  REDIS = "redis"
  VERTICA = "vertica"
  
  _mysql_compatible_datastores = (MYSQL, MARIA, PERCONA, PERCONA_CLUSTER)
  _cluster_capable_datastores = (CASSANDRA, MARIA, MONGODB, PERCONA_CLUSTER,
!                                REDIS, VERTICA)
  _cluster_grow_shrink_capable_datastores = (CASSANDRA, MARIA, MONGODB,
!                                            PERCONA_CLUSTER, REDIS)
  
  
  def can_modify_cluster(datastore):
--- 21,33 ----
  PERCONA_CLUSTER = "pxc"
  REDIS = "redis"
  VERTICA = "vertica"
+ K2HDKC = "k2hdkc"
  
  _mysql_compatible_datastores = (MYSQL, MARIA, PERCONA, PERCONA_CLUSTER)
  _cluster_capable_datastores = (CASSANDRA, MARIA, MONGODB, PERCONA_CLUSTER,
!                                REDIS, VERTICA, K2HDKC)
  _cluster_grow_shrink_capable_datastores = (CASSANDRA, MARIA, MONGODB,
!                                            PERCONA_CLUSTER, REDIS, K2HDKC)
  
  
  def can_modify_cluster(datastore):
