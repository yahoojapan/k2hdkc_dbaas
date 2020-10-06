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

*** /opt/stack/trove/trove/common/configurations.py	2020-06-09 16:18:00.762190008 +0900
--- configurations.py	2020-06-11 13:28:21.189458201 +0900
***************
*** 95,97 ****
--- 95,107 ----
  
      def parse(self):
          return self.CODEC.deserialize(self.config).items()
+ 
+ class K2hdkcConfParser(object):
+ 
+     CODEC = stream_codecs.KeyValueCodec(delimiter='=', comment_marker='#', line_terminator='\n')
+ 
+     def __init__(self, config):
+         self.config = config
+ 
+     def parse(self):
+         return self.CODEC.deserialize(self.config).items()
