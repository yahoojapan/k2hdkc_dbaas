---
layout: contents
language: en-us
title: Overview DBaaS CLI
short_desc: Database as a Service for K2HDKC
lang_opp_file: overview_clija.html
lang_opp_word: To Japanese
prev_url: overview_trove.html
prev_string: Overview DBaaS with Trove
top_url: overview.html
top_string: Overview
next_url: overview_k8s_cli.html
next_string: Overview DBaaS on k8s CLI
---

# Overview - OpenStack and K2HDKC DBaaS CLI(Command Line Interface)
**DBaaS(Database as a Service)** using **K2HDKC DBaaS CLI**(Command Line Interface) does **not require** [Trove](https://wiki.openstack.org/wiki/Trove) and only works with [OpenStack](https://www.openstack.org/) components.  
In an environment where you already have an [OpenStack](https://www.openstack.org/) environment and it is difficult to incorporate [Trove](https://wiki.openstack.org/wiki/Trove) components, but you can realize the function as **DBaaS(Database as a Service)**.  

![K2HDKC DBaaS CLI Overview](images/overview_cli.png)

All operations such as building a **K2HDKC cluster** with **K2HDKC DBaaS** can be performed from the **K2HDKC DBaaS CLI**.  
You can build and delete K2HDKC clusters, and add/remove(scale) server nodes to the cluster.  
In addition, it supports K2HDKC slave node startup and automatic configuration so that it can be easily connected to and used in the built K2HDKC cluster.  

Below is a rough description of the **K2HDKC DBaaS** system using the **K2HDKC DBaaS CLI**.  

## OpenStack components
**K2HDKC DBaaS CLI** works with [OpenStack](https://www.openstack.org/) components.  
This [OpenStack](https://www.openstack.org/) component assumes an existing system, and ** K2HDKC DBaaS CLI** can be linked as long as the environment can start an instance(`Virtual Machine`).  

## K2HR3 system
Like the Trove type **K2HDKC DBaaS**, this type requires the [K2HR3](https://k2hr3.antpick.ax/) system, which is one of the [AntPickax](https://antpick.ax/index.html) products.  
**K2HDKC DBaaS CLI** operates [K2HR3](https://k2hr3.antpick.ax/) system and [OpenStack](https://www.openstack.org/) components to realize **DBaaS(Database as a Service)** function.  
Also, like the Trove type, the [K2HR3](https://k2hr3.antpick.ax/) system must be built in a network environment that can be accessed by [OpenStack](https://www.openstack.org/) components and instances(`Virtual Machine`).  

## K2HDKC cluster
This is a **K2HDKC cluster** built and launched by the **K2HDKC DBaaS CLI**.  
K2HDKC server nodes are started on multiple instances managed by [OpenStack](https://www.openstack.org/) (`Virtual Machine`) to form a cluster.  
The function of the **K2HDKC DBaaS CLI** is to build, destroy, and control(scaling, merging data) this K2HDKC cluster.  

## K2HDKC slave node
A K2HDKC slave node is a client node that connects to a **K2HDKC cluster**(server nodes) created by the **K2HDKC DBaaS CLI**.  

![K2HDKC DBaaS Slave Overview](images/overview_cli_slave.png)

K2HDKC slave nodes can also be booted using the **K2HDKC DBaaS CLI**.  
And the **K2HDKC DBaaS CLI** supports automatic configuration.  
A K2HDKC slave node is an instance of [OpenStack](https://www.openstack.org/) (`Virtual Machine`) launched by the **K2HDKC DBaaS CLI**.  
The instance of the K2HDKC slave node(`Virtual Machine`) uses the `User Data Script for OpenStack` data provided by [K2HR3](https://k2hr3.antpick.ax/).  
In addition, the K2HDKC slave node instance works with the [K2HR3](https://k2hr3.antpick.ax/) system to automate the K2HDKC configuration required to connect to the K2HDKC cluster and all package installation and initialization required for the K2HDKC slave node.  

Similar to the Trove type, the booted K2HDKC slave node can automate processes such as connecting and disconnecting according to the scale of the K2HDKC server node.  
Then, the K2HDK cluster configuration is hidden from the user's program on the K2HDKC slave node, and the user's program does not need to be aware of the server node configuration, reducing the load on developers and operators.  
