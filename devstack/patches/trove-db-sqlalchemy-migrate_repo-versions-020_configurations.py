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

*** /opt/stack/trove/trove/db/sqlalchemy/migrate_repo/versions/020_configurations.py	2020-06-09 16:18:00.773190227 +0900
--- 020_configurations.py	2020-06-11 11:16:37.957435544 +0900
***************
*** 44,50 ****
      Column('configuration_id', String(36), ForeignKey("configurations.id"),
             nullable=False, primary_key=True),
      Column('configuration_key', String(128), nullable=False, primary_key=True),
!     Column('configuration_value', String(128)),
      Column('deleted', Boolean(), nullable=False, default=False),
      Column('deleted_at', DateTime()),
  )
--- 44,50 ----
      Column('configuration_id', String(36), ForeignKey("configurations.id"),
             nullable=False, primary_key=True),
      Column('configuration_key', String(128), nullable=False, primary_key=True),
!     Column('configuration_value', String(512)),
      Column('deleted', Boolean(), nullable=False, default=False),
      Column('deleted_at', DateTime()),
  )
