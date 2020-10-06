# -*- coding: utf-8 -*-
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
"""OpenStack Trove for K2HDKC."""

from oslo_log import log as logging
from trove.cluster import models
from trove.cluster.tasks import ClusterTasks
from trove.cluster.views import ClusterView
from trove.common import cfg
from trove.common import exception
from trove.common import server_group as srv_grp
from trove.common import utils
from trove.common.strategies.cluster import base
from trove.extensions.mgmt.clusters.views import MgmtClusterView
from trove.instance import models as inst_models
from trove.quota.quota import check_quotas
from trove.taskmanager import api as task_api

LOG = logging.getLogger(__name__)
CONF = cfg.CONF


class K2hdkcAPIStrategy(base.BaseAPIStrategy):
    """OpenStack Clusters API endpoint implementation."""

    @property
    def cluster_class(self):
        """Implement BaseAPIStrategy.cluster_class."""
        LOG.debug("cluster_class")
        return K2hdkcCluster

    @property
    def cluster_controller_actions(self):
        """Implement BaseAPIStrategy.cluster_controller_actions."""
        LOG.debug("cluster_controller_actions")
        return {
            'grow': self._action_grow_cluster,
            'shrink': self._action_shrink_cluster
        }

    def _action_grow_cluster(self, cluster, body):  # pylint: disable=no-self-use
        """Grow cluster."""
        LOG.debug("_action_grow_cluster cluster={} body={}"
                  .format(cluster, body))
        nodes = body['grow']
        instances = []
        for node in nodes:
            instance = {'flavor_id': utils.get_id_from_href(node['flavorRef'])}
            if 'name' in node:
                instance['name'] = node['name']
            if 'volume' in node:
                instance['volume_size'] = int(node['volume']['size'])
            instances.append(instance)
        return cluster.grow(instances)

    def _action_shrink_cluster(self, cluster, body):  # pylint: disable=no-self-use
        """Shrink cluster."""
        LOG.debug("_action_shrink_cluster cluster={} body={}".format(
            cluster, body))
        nodes = body['shrink']
        instance_ids = [node['id'] for node in nodes]
        return cluster.shrink(instance_ids)

    @property
    def cluster_view_class(self):
        """Implement BaseAPIStrategy.cluster_view_class."""
        return K2hdkcClusterView

    @property
    def mgmt_cluster_view_class(self):
        """Implement. BaseAPIStrategy.mgmt_cluster_view_class."""
        return K2hdkcMgmtClusterView


class K2hdkcCluster(models.Cluster):
    """Create K2hdkc Cluster data to Trove DB and OpenStack services."""

    @staticmethod
    def _create_insts(context, cluster_id, cluster_name, datastore,
                      datastore_version, instances, locality, configuration_id
                     ):  # pylint: disable=too-many-arguments, too-many-locals

        # 1. Check quotas
        num = len(instances)
        manager_conf = CONF.get(datastore_version.manager)
        total_volume_allocation = models.get_required_volume_size(
            instances, manager_conf.volume_support)
        quota_request = {'instances': num, 'volumes': total_volume_allocation}
        check_quotas(context.project_id, quota_request)

        # 2. Name new instances
        alls = inst_models.DBInstance.find_all(cluster_id=cluster_id).all()
        index = 1
        if alls:
            index += len(alls)

        # 3. Create instances
        new_insts = []
        member_config = {"id": cluster_id, "instance_type": "member"}
        for instance in instances:
            if not instance.get('name'):
                instance['name'] = "%s-member-%s" % (cluster_name, index)
                index += 1
            instance_name = instance.get('name')
            instance_az = instance.get('availability_zone', None)
            LOG.debug("new instance_name=%s instance_az=%s", instance_name,
                      instance_az)
            new_inst = inst_models.Instance.create(
                context,
                instance_name,
                instance['flavor_id'],
                datastore_version.image_id, [], [],
                datastore,
                datastore_version,
                instance['volume_size'],
                None,
                nics=instance.get('nics', None),
                availability_zone=instance_az,
                configuration_id=configuration_id,
                cluster_config=member_config,
                volume_type=instance.get('volume_type', None),
                modules=instance.get('modules'),
                locality=locality,
                region_name=instance.get('region_name'))
            new_insts.append(new_inst)
        return new_insts

    @classmethod
    def create(cls, context, name, datastore, datastore_version, instances,
               extended_properties, locality, configuration
              ):  # pylint: disable=too-many-arguments, too-many-locals
        """Create Clusters API endpoint.

        main function to create a cluster is here
        https://github.com/openstack/trove/blob/master/trove/cluster/service.py#L162-L234
        """

        # 1. validates args
        if context is None:
            LOG.error("no context")
            return None
        if name is None:
            LOG.error("no name")
            return None
        if datastore is None:
            LOG.error("no datastore")
            return None
        if datastore_version is None:
            LOG.error("no datastore_version")
            return None
        if instances is None:
            LOG.error("no instances")
            return None
        models.assert_homogeneous_cluster(instances)
        manager_conf = CONF.get(datastore_version.manager)
        models.validate_instance_flavors(context, instances,
                                         manager_conf.volume_support,
                                         manager_conf.device_path)
        models.validate_instance_nics(context, instances)

        # 2. Insert a cluster data to clusters table
        db_info = models.DBCluster.create(
            name=name,
            tenant_id=context.project_id,
            datastore_version_id=datastore_version.id,
            configuration_id=configuration,
            task_status=ClusterTasks.BUILDING_INITIAL)

        # 3. Create instances in OpenStack
        cls._create_insts(context, db_info.id, db_info.name, datastore,
                          datastore_version, instances, locality,
                          configuration)

        # 4. Calling taskmanager to further proceed for cluster-configuration
        LOG.debug(
            "Calling taskmanager to further proceed for "
            "cluster-configuration of %s", db_info.id)
        task_api.load(context,
                      datastore_version.manager).create_cluster(db_info.id)

        # 5. Returns cluster instance to render HTTP response.
        return K2hdkcCluster(context, db_info, datastore, datastore_version)

    def grow(self, instances):
        """Grow Cluster API endpoint.

        main function to grow a cluster is here.
        https://github.com/openstack/trove/blob/master/trove/cluster/service.py#L60-L86
        https://github.com/openstack/trove/blob/master/trove/cluster/models.py#L305
        """
        LOG.debug("Growing cluster. %s", "{}".format(instances))

        # 1. validates args
        if not instances:
            LOG.error("no instances")
            return False
        models.assert_homogeneous_cluster(instances)
        manager_conf = CONF.get(self.datastore_version.manager)
        models.validate_instance_flavors(self.context, instances,
                                         manager_conf.volume_support,
                                         manager_conf.device_path)
        self.validate_cluster_available()

        # 2. updates the cluster status
        self.db_info.update(task_status=ClusterTasks.GROWING_CLUSTER)

        # 3. creates new instances by using self._create_insts
        locality = srv_grp.ServerGroup.convert_to_hint(self.server_group)
        new_insts = self._create_insts(self.context, self.db_info.id,
                                       self.db_info.name, self.ds,
                                       self.ds_version, instances,
                                       locality, self.db_info.configuration_id)
        # 4. calls the taskmanager's grow_cluster endpoint
        task_api.load(self.context, self.ds_version.manager).grow_cluster(
            self.db_info.id, [instance.id for instance in new_insts])

        return True

    def shrink(self, removal_ids):  # pylint: disable=arguments-differ
        """Shrink Cluster API endpoint.

        main function to shrink a cluster is here.
        https://github.com/openstack/trove/blob/master/trove/cluster/service.py#L60-L86
        https://github.com/openstack/trove/blob/master/trove/cluster/models.py#L305
        """
        LOG.debug("Shrinking cluster {} {}".format(self.id, removal_ids))

        # 1. validates args
        if not removal_ids:
            LOG.error("no removal_ids")
            return False
        self.validate_cluster_available()

        # 2. updates the cluster status
        self.db_info.update(task_status=ClusterTasks.SHRINKING_CLUSTER)

        # 3. calls the taskmanager's grow_cluster endpoint
        task_api.load(self.context, self.ds_version.manager).shrink_cluster(
            self.db_info.id, removal_ids)

        return True

    def upgrade(self, datastore_version):   # pylint: disable=no-self-use
        """Return the source code for the definition."""
        LOG.debug("Upgrading cluster %s", datastore_version)
        if not datastore_version:
            LOG.error("no datastore_version")
            return False
        raise exception.BadRequest("Action 'upgrade' not supported")


class K2hdkcClusterView(ClusterView):   # pylint: disable=too-few-public-methods
    """K2hdkcClusterView class."""

    def build_instances(self):
        """Build instances."""
        return self._build_instances(['member'], ['member'])


class K2hdkcMgmtClusterView(MgmtClusterView):   # pylint: disable=too-few-public-methods
    """K2hdkcMgmtClusterView class."""

    def build_instances(self):
        """Build instances."""
        return self._build_instances(['member'], ['member'])
#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
