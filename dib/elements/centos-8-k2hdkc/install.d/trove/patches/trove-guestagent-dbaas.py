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

*** trove-guestagent-dbaas.py	2020-05-07 04:45:33.958268000 +0000
--- dbaas.py	2020-05-07 04:47:38.404460003 +0000
***************
*** 58,64 ****
      'db2':
      'trove.guestagent.datastore.experimental.db2.manager.Manager',
      'mariadb':
!     'trove.guestagent.datastore.experimental.mariadb.manager.Manager'
  }
  CONF = cfg.CONF
  
--- 58,66 ----
      'db2':
      'trove.guestagent.datastore.experimental.db2.manager.Manager',
      'mariadb':
!     'trove.guestagent.datastore.experimental.mariadb.manager.Manager',
!     'k2hdkc':
!     'trove.guestagent.datastore.experimental.k2hdkc.manager.Manager'
  }
  CONF = cfg.CONF
  
