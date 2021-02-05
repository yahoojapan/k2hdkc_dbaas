#!/bin/sh

cd ~/devstack
cat > ./patch-stack-sh.txt << EOF
diff --git a/stack.sh b/stack.sh
index 036afd7b..ddefb1db 100755
--- a/stack.sh
+++ b/stack.sh
@@ -352,9 +352,9 @@ if [[ $DISTRO == "rhel8" ]]; then
         sudo dnf config-manager --set-enabled epel
     fi

-    # PowerTools repo provides libyaml-devel required by devstack itself and
-    # EPEL packages assume that the PowerTools repository is enable.
-    sudo dnf config-manager --set-enabled PowerTools
+    # powertools repo provides libyaml-devel required by devstack itself and
+    # EPEL packages assume that the powertools repository is enable.
+    sudo dnf config-manager --set-enabled powertools

     if [[ ${SKIP_EPEL_INSTALL} != True ]]; then
         _install_epel
EOF

patch ./stack.sh < ./patch-stack-sh.txt

