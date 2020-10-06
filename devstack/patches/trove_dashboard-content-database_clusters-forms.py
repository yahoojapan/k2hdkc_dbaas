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

diff --git a/trove_dashboard/content/database_clusters/forms.py b/trove_dashboard/content/database_clusters/forms.py
index 6539055..803d4f3 100644
--- a/trove_dashboard/content/database_clusters/forms.py
+++ b/trove_dashboard/content/database_clusters/forms.py
@@ -40,7 +40,51 @@ from trove_dashboard.utils import common as common_utils
 LOG = logging.getLogger(__name__)
 
 
-class LaunchForm(forms.SelfHandlingForm):
+class BaseClusterForm(forms.SelfHandlingForm):
+    def __init__(self, request, *args, **kwargs):
+        super(BaseClusterForm, self).__init__(request, *args, **kwargs)
+
+    @memoized.memoized_method
+    def populate_network_choices(self, request):
+        network_list = []
+        try:
+            if api.base.is_service_enabled(request, 'network'):
+                tenant_id = self.request.user.tenant_id
+                networks = api.neutron.network_list_for_tenant(request,
+                                                               tenant_id)
+                network_list = [(network.id, network.name_or_id)
+                                for network in networks]
+            else:
+                self.fields['network'].widget = forms.HiddenInput()
+        except exceptions.ServiceCatalogException:
+            network_list = []
+            redirect = reverse('horizon:project:database_clusters:index')
+            exceptions.handle(request,
+                              _('Unable to retrieve networks.'),
+                              redirect=redirect)
+        return network_list
+
+    @memoized.memoized_method
+    def populate_cg_choices(self, request):
+        try:
+            configs = trove_api.trove.configuration_list(request)
+            config_name = "%(name)s (%(datastore)s - %(version)s)"
+            choices = [(c.id,
+                        config_name % {'name': c.name,
+                                       'datastore': c.datastore_name,
+                                       'version': c.datastore_version_name})
+                       for c in configs]
+        except Exception:
+            choices = []
+
+        if choices:
+            choices.insert(0, ("", _("Select configuration")))
+        else:
+            choices.insert(0, ("", _("No configurations available")))
+        return choices
+
+
+class LaunchForm(BaseClusterForm):
     name = forms.CharField(label=_("Cluster Name"),
                            max_length=80)
     datastore = forms.ChoiceField(
@@ -68,6 +112,10 @@ class LaunchForm(forms.SelfHandlingForm):
         help_text=_("Specify whether instances in the cluster will "
                     "be created on the same hypervisor (affinity) or on "
                     "different hypervisors (anti-affinity)."))
+    configuration = forms.ChoiceField(
+        label=_("ConfigurationGroup"),
+        help_text=_("ConfigurationGroup attached to instances."),
+        required=False)
     root_password = forms.CharField(
         label=_("Root Password"),
         required=False,
@@ -127,6 +175,8 @@ class LaunchForm(forms.SelfHandlingForm):
             request)
         self.fields['network'].choices = self.populate_network_choices(
             request)
+        self.fields['configuration'].choices = self.populate_cg_choices(
+            request)
 
     def clean(self):
         datastore_field_value = self.data.get("datastore", None)
@@ -158,6 +208,9 @@ class LaunchForm(forms.SelfHandlingForm):
         if not self.data.get("locality", None):
             self.cleaned_data["locality"] = None
 
+        if not self.data.get("configuration", None):
+            self.cleaned_data["configuration"] = None
+
         return self.cleaned_data
 
     @memoized.memoized_method
@@ -173,26 +226,6 @@ class LaunchForm(forms.SelfHandlingForm):
                               _('Unable to obtain flavors.'),
                               redirect=redirect)
 
-    @memoized.memoized_method
-    def populate_network_choices(self, request):
-        network_list = []
-        try:
-            if api.base.is_service_enabled(request, 'network'):
-                tenant_id = self.request.user.tenant_id
-                networks = api.neutron.network_list_for_tenant(request,
-                                                               tenant_id)
-                network_list = [(network.id, network.name_or_id)
-                                for network in networks]
-            else:
-                self.fields['network'].widget = forms.HiddenInput()
-        except exceptions.ServiceCatalogException:
-            network_list = []
-            redirect = reverse('horizon:project:database_clusters:index')
-            exceptions.handle(request,
-                              _('Unable to retrieve networks.'),
-                              redirect=redirect)
-        return network_list
-
     @memoized.memoized_method
     def datastores(self, request):
         try:
@@ -354,9 +387,10 @@ class LaunchForm(forms.SelfHandlingForm):
             LOG.info("Launching cluster with parameters "
                      "{name=%s, volume=%s, flavor=%s, "
                      "datastore=%s, datastore_version=%s",
-                     "locality=%s",
+                     "locality=%s, configuration=%s",
                      data['name'], data['volume'], flavor,
-                     datastore, datastore_version, self._get_locality(data))
+                     datastore, datastore_version, self._get_locality(data),
+                     configuration=data['configuration'])
 
             trove_api.trove.cluster_create(request,
                                            data['name'],
@@ -367,7 +401,8 @@ class LaunchForm(forms.SelfHandlingForm):
                                            datastore_version=datastore_version,
                                            nics=data['network'],
                                            root_password=root_password,
-                                           locality=self._get_locality(data))
+                                           locality=self._get_locality(data),
+                                           configuration=data['configuration'])
             messages.success(request,
                              _('Launched cluster "%s"') % data['name'])
             return True
@@ -378,7 +413,7 @@ class LaunchForm(forms.SelfHandlingForm):
                               redirect=redirect)
 
 
-class ClusterAddInstanceForm(forms.SelfHandlingForm):
+class ClusterAddInstanceForm(BaseClusterForm):
     cluster_id = forms.CharField(
         required=False,
         widget=forms.HiddenInput())
@@ -408,6 +443,10 @@ class ClusterAddInstanceForm(forms.SelfHandlingForm):
         label=_("Network"),
         help_text=_("Network attached to instance."),
         required=False)
+    configuration = forms.ChoiceField(
+        label=_("ConfigurationGroup"),
+        help_text=_("ConfigurationGroup attached to instance."),
+        required=False)
 
     def __init__(self, request, *args, **kwargs):
         super(ClusterAddInstanceForm, self).__init__(request, *args, **kwargs)
@@ -415,6 +454,8 @@ class ClusterAddInstanceForm(forms.SelfHandlingForm):
         self.fields['flavor'].choices = self.populate_flavor_choices(request)
         self.fields['network'].choices = self.populate_network_choices(
             request)
+        self.fields['configuration'].choices = self.populate_cg_choices(
+            request)
 
     @memoized.memoized_method
     def flavors(self, request):
@@ -441,26 +482,6 @@ class ClusterAddInstanceForm(forms.SelfHandlingForm):
         flavor_list = [(f.id, "%s" % f.name) for f in self.flavors(request)]
         return sorted(flavor_list)
 
-    @memoized.memoized_method
-    def populate_network_choices(self, request):
-        network_list = []
-        try:
-            if api.base.is_service_enabled(request, 'network'):
-                tenant_id = self.request.user.tenant_id
-                networks = api.neutron.network_list_for_tenant(request,
-                                                               tenant_id)
-                network_list = [(network.id, network.name_or_id)
-                                for network in networks]
-            else:
-                self.fields['network'].widget = forms.HiddenInput()
-        except exceptions.ServiceCatalogException:
-            network_list = []
-            redirect = reverse('horizon:project:database_clusters:index')
-            exceptions.handle(request,
-                              _('Unable to retrieve networks.'),
-                              redirect=redirect)
-        return network_list
-
     def handle(self, request, data):
         try:
             flavor = trove_api.trove.flavor_get(request, data['flavor'])
