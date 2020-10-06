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
"""OpenStack Clusters API taskmanager implementation."""

from eventlet.timeout import Timeout
from oslo_log import log as logging
import trove.taskmanager.models as task_models
from trove.common import cfg
from trove.common.exception import GuestError, GuestTimeout
from trove.common.strategies.cluster import base
from trove.instance import tasks as inst_tasks
from trove.instance.models import DBInstance
from trove.instance.models import Instance
from trove.taskmanager import api as task_api

LOG = logging.getLogger(__name__)
CONF = cfg.CONF


class K2hdkcTaskManagerStrategy(base.BaseTaskManagerStrategy):
    """OpenStack Clusters API taskmanager implementation."""

    @property
    def task_manager_api_class(self):  # pylint: disable=arguments-differ
        """Implement BaseTaskManagerStrategy.task_manager_api_class."""
        return K2hdkcTaskManagerAPI

    @property
    def task_manager_cluster_tasks_class(self):  # pylint: disable=arguments-differ
        """Implement BaseTaskManagerStrategy.task_manager_tasks_class."""
        return K2hdkcClusterTasks


class K2hdkcClusterTasks(task_models.ClusterTasks):
    """Create Clusters API taskmanager endpoint."""

    def create_cluster(self, context, cluster_id):
        """Create K2hdkcClusterTasks.

        This function is called in trove.taskmanager.Manager.create_cluster.
        """

        LOG.debug("Begins create_cluster for %s.", cluster_id)

        # 1. validates args
        if context is None:
            LOG.error("no context")
            return
        if cluster_id is None:
            LOG.error("no cluster_id")
            return

        timeout = Timeout(CONF.cluster_usage_timeout)
        LOG.debug("CONF.cluster_usage_timeout %s.", timeout)
        try:
            # 2. Retrieves db_instances from the database
            db_instances = DBInstance.find_all(cluster_id=cluster_id,
                                               deleted=False).all()
            # 3. Retrieves instance ids from the db_instances
            instance_ids = [db_instance.id for db_instance in db_instances]
            # 4. Checks if instances are ready
            if not self._all_instances_running(instance_ids, cluster_id):
                LOG.error("instances are not ready yet")
                return
            # 5. Loads instances
            instances = [
                Instance.load(context, instance_id)
                for instance_id in instance_ids
            ]
            # 6. Instantiates GuestAgent for each guest instance
            # 7. Calls cluster_complete endpoint of K2hdkcGuestAgent
            for instance in instances:
                self.get_guest(instance).cluster_complete()
            # 8. reset the current cluster task status to None
            LOG.debug("reset cluster task to None")
            self.reset_task()
        except Timeout:
            # Note adminstrators should reset task via CLI in this case.
            if Timeout is not timeout:
                raise  # not my timeout
            LOG.exception("Timeout for building cluster.")
            self.update_statuses_on_failure(cluster_id)
        finally:
            timeout.cancel()

        LOG.debug("Completed create_cluster for %s.", cluster_id)

    def grow_cluster(self, context, cluster_id, new_instance_ids):
        """Grow a K2hdkc Cluster."""
        LOG.debug("Begins grow_cluster for %s. new_instance_ids:{}"
                  .format(new_instance_ids), cluster_id)

        # 1. validates args
        if context is None:
            LOG.error("no context")
            return
        if cluster_id is None:
            LOG.error("no cluster_id")
            return
        if new_instance_ids is None:
            LOG.error("no new_instance_ids")
            return

        timeout = Timeout(CONF.cluster_usage_timeout)
        try:
            # 2. Retrieves db_instances from the database
            db_instances = DBInstance.find_all(cluster_id=cluster_id,
                                               deleted=False).all()
            LOG.debug("len(db_instances) {}".format(len(db_instances)))
            # 3. Checks if new instances are ready
            if not self._all_instances_running(new_instance_ids, cluster_id):
                LOG.error("instances are not ready yet")
                return
            # 4. Loads instances
            instances = [
                Instance.load(context, instance_id)
                for instance_id in new_instance_ids
            ]
            LOG.debug("len(instances) {}".format(len(instances)))

            # 5. Instances GuestAgent class
            # 6. Calls cluster_complete endpoint of K2hdkcGuestAgent
            LOG.debug("Calling cluster_complete as a final hook to each node in the cluster")
            for instance in instances:
                self.get_guest(instance).cluster_complete()
            # 7. reset the current cluster task status to None
            LOG.debug("reset cluster task to None")
            self.reset_task()
        except Timeout:
            # Note adminstrators should reset task via CLI in this case.
            if Timeout is not timeout:
                raise  # not my timeout
            LOG.exception("Timeout for growing cluster.")
            self.update_statuses_on_failure(
                cluster_id, status=inst_tasks.InstanceTasks.GROWING_ERROR)
        finally:
            timeout.cancel()

        LOG.debug("Completed grow_cluster for %s.", cluster_id)

    def shrink_cluster(self, context, cluster_id, removal_ids):
        """Shrink a K2hdkc Cluster."""
        LOG.debug("Begins shrink_cluster for %s. removal_ids:{}"
                  .format(removal_ids), cluster_id)

        # 1. validates args
        if context is None:
            LOG.error("no context")
            return
        if cluster_id is None:
            LOG.error("no cluster_id")
            return
        if removal_ids is None:
            LOG.error("no removal_ids")
            return

        timeout = Timeout(CONF.cluster_usage_timeout)
        try:
            # 2. Retrieves db_instances from the database
            db_instances = DBInstance.find_all(cluster_id=cluster_id,
                                               deleted=False).all()
            # 3. Retrieves instance ids from the db_instances
            instance_ids = [db_instance.id for db_instance in db_instances]
            # 4. Checks if instances are running
            if not self._all_instances_running(instance_ids, cluster_id):
                LOG.error("instances are not ready yet")
                return
            # 4. Loads instances
            instances = [
                Instance.load(context, instance_id)
                for instance_id in removal_ids
            ]
            LOG.debug("len(instances) {}".format(len(instances)))

            # 5. Instances GuestAgent class
            # 6.2. Checks if removing instances are 
            # if not self._all_instances_shutdown(removal_ids, cluster_id):
            #    LOG.error("removing instances are not shutdown yet")
            #    return
            # 7. Calls cluster_complete endpoint of K2hdkcGuestAgent
            LOG.debug("Calling cluster_complete as a final hook to each node in the cluster")
            for instance in instances:
                self.get_guest(instance).cluster_complete()
            # 8. delete node from OpenStack
            LOG.debug("delete node from OpenStack")
            for instance in instances:
                Instance.delete(instance)
            # 9. reset the current cluster task status to None
            LOG.debug("reset cluster task to None")
            self.reset_task()
        except Timeout:
            # Note adminstrators should reset task via CLI in this case.
            if Timeout is not timeout:
                raise  # not my timeout
            LOG.exception("Timeout for shrink cluster.")
            self.update_statuses_on_failure(
                cluster_id, status=inst_tasks.InstanceTasks.SHRINKING_ERROR)
        finally:
            timeout.cancel()

        LOG.debug("Completed shrink_cluster for %s.", cluster_id)


class K2hdkcTaskManagerAPI(task_api.API):   # pylint: disable=too-few-public-methods
    """OpenStack Clusters API taskmanager API class implementation."""

#
# Local variables:
# tab-width: 4
# c-basic-offset: 4
# End:
# vim600: expandtab sw=4 ts=4 fdm=marker
# vim<600: expandtab sw=4 ts=4
#
