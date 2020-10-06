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

*** /opt/stack/trove/trove/common/template.py	2020-06-09 16:18:00.770190167 +0900
--- template.py	2020-06-11 13:28:27.540584594 +0900
***************
*** 38,43 ****
--- 38,44 ----
      'redis': configurations.RedisConfParser,
      'vertica': configurations.VerticaConfParser,
      'db2': configurations.DB2ConfParser,
+     'k2hdkc': configurations.K2hdkcConfParser,
  }
  
  
