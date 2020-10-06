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

diff --git a/trove_dashboard/enabled/_1740_project_database_clusters_panel.py b/trove_dashboard/enabled/_1740_project_database_clusters_panel.py
index a5d3164..ccada2d 100644
--- a/trove_dashboard/enabled/_1740_project_database_clusters_panel.py
+++ b/trove_dashboard/enabled/_1740_project_database_clusters_panel.py
@@ -22,7 +22,7 @@ PANEL_DASHBOARD = 'project'
 # The slug of the panel group the PANEL is associated with.
 PANEL_GROUP = 'database'
 
-DISABLED = True
+DISABLED = False
 
 # Python panel class of the PANEL to be added.
 ADD_PANEL = ('trove_dashboard.content.database_clusters.panel.Clusters')
