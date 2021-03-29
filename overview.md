---
layout: contents
language: en-us
title: Overview
short_desc: Database as a Service for K2HDKC
lang_opp_file: overviewja.html
lang_opp_word: To Japanese
prev_url: 
prev_string: 
top_url: index.html
top_string: TOP
next_url: whatnew.html
next_string: What's new
---

# **K2HDKC DBaaS**
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that uses [K2HR3](https://k2hr3.antpick.ax/) and works with [OpenStack](https://www.openstack.org/) to build a [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) Cluster for distributed KVS.

## Background
Yahoo! JAPAN publishes some products as [AntPickax](https://antpick.ax/) as Open Source Software(OSS).  
We planned to provide one of them, [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/) as **DBaaS(Database as a Service)** so that anyone can easily use it.  
And the publicly available [K2HR3(K2Hdkc based Resource and Roles and policy Rules)](https://k2hr3.antpick.ax/) offers enough features to make this happen.  
We have built ** DBaaS (Database as a Service)** in conjunction with [OpenStack](https://www.openstack.org/), centering on this [K2HR3(K2Hdkc based Resource and Roles and policy Rules)](https://k2hr3.antpick.ax/).  

**K2HDKC DBaaS** (Database as a Service for K2HDKC) is configured using the following products which is provided by [AntPickax](https://antpick.ax/index.html).  

### [K2HDKC](https://k2hdkc.antpick.ax/) - K2Hash based Distributed Kvs Cluster
This product is distributed KVS(Key Value Store) clustering system and the core product of **K2HDKC DBaaS**.
### [CHMPX](https://chmpx.antpick.ax/) - Consistent Hashing Mq inProcess data eXchange
This product is communication middleware over the network for sending binary data and an important component responsible for [K2HDKC](https://k2hdkc.antpick.ax/) communication.
### [K2HR3](https://k2hr3.antpick.ax/) - K2Hdkc based Resource and Roles and policy Rules
This is extended RBAC (Role Based Access Control) system, and this system manages the configuration of the **K2HDKC cluster** as a backend for **K2HDKC DBaaS**.

# Overview
**K2HDKC DBaaS** (Database as a Service for K2HDKC) provides the following **two ways** to build **DBaaS(Database as a Service)**.

## With Trove(Trove is Database as a Service for OpenStack)
This is **DBaaS(Database as a Service)** using [Trove](https://wiki.openstack.org/wiki/Trove) which is a product of [OpenStack](https://www.openstack.org/).  
It incorporates [K2HDKC](https://k2hdkc.antpick.ax/) (Distributed KVS) as one of Trove's databases to realize **DBaaS(Database as a Service)**.  

## OpenStack and K2HDKC DBaaS CLI(Command Line Interface)
If you have an existing [OpenStack](https://www.openstack.org/) environment, this **K2HDKC DBaaS CLI(Command Line Interface)** allows you to implement **DBaaS(Database as a Service)** without any changes.

# Overview - With Trove(Trove is Database as a Service for OpenStack)
**K2HDKC DBaaS**(Database as a Service for K2HDKC) is based on [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) and works with other [OpenStack](https://www.openstack.org/) components.  

![K2HDKC DBaaS Overview](images/overview.png)

**K2HDKC DBaaS** K2HDKC cluster construction and operation are performed from **Dashboard(Trove Dashboard)** or **Trove CLI(openstack command)**.  
You can use it to build and remove **K2HDKC clusters**, add and remove(scale) server nodes in the cluster, and perform backup and restore operations.  
**K2HDKC DBaaS** also supports the construction of **K2HDKC slave nodes** that can be easily connected to **K2HDKC clusters** and their **automatic configuration**.  

Below is a brief description of the **K2HDKC DBaaS** system.  

## About OpenStack components

**K2HDKC DBaaS** requires OpenStack components.  
The system administrator is responsible for building each component of OpenStack and the entire structure.  
It is also possible to incorporate **K2HDKC DBaaS** into existing your OpenStack system.  
[Trove](https://wiki.openstack.org/wiki/Trove) is one of the OpenStack components, and **K2HDKC DBaaS** is included as one of that Trove's Database.  
In other words, **K2HDKC DBaaS** is a system that extends [K2HDKC](https://k2hdkc.antpick.ax/) to Trove's Database type.  
The basic specifications of **K2HDKC DBaaS** all follow [Trove](https://wiki.openstack.org/wiki/Trove), and you can operate and operate **K2HDKC cluster** as DBaaS by Trove.  

## K2HR3 system
**K2HDKC DBaaS** requires the [K2HR3](https://k2hr3.antpick.ax/) system, which is one of the [AntPickax](https://antpick.ax/) products.  
[K2HR3](https://k2hr3.antpick.ax/) system and Trove work together to provide the DBaaS system.  
[K2HR3](https://k2hr3.antpick.ax/) is designed to work with OpenStack and is used as Trove's backend system.  

[K2HR3](https://k2hr3.antpick.ax/) system must be built in a network that can be accessed from OpenStack components and instances(`Virtual Machine`).  
For example, you can build [K2HR3](https://k2hr3.antpick.ax/) system in instances(`Virtual Machine`s) which are created by OpenStack that works for **K2HDKC DBaaS**.  

## K2HDKC Clusters
**K2HDKC Cluster** is a cluster of K2HDKC that is built by user using **K2HDKC DBaaS**.  
**K2HDKC cluster** is a cluster consisting of multiple K2HDKC server nodes launched on instances(`Virtual Machine`) managed by OpenStack.  
**K2HDKC DBaaS** builds, destroys, and controls(scales, data merges) these K2HDKC clusters.  

## K2HDKC Slave nodes
**K2HDKC slave node** is the client that connects to a K2HDKC cluster(server nodes) created by **K2HDKC DBaaS**.  

![K2HDKC DBaaS Slave Overview](images/overview_slave.png)

You can manually configure and boot the **K2HDKC slave node**.  
In addition, you can easily boot the **K2HDKC slave node** and take advantage of automatic configuration by using the features of **K2HDKC DBaaS**.  
When using **K2HDKC DBaaS** for **K2HDKC slave node**, you starts an instance(`Virtual Machine`) of OpenStack linked with **K2HDKC DBaaS** as a HOST for the slave node of K2HDKC.  
When launching this instance(`Virtual Machine`), you use the `User Data Script for OpenStack` data provided by [K2HR3](https://k2hr3.antpick.ax/).  
This allows the booted instance(`Virtual Machine`) to work with the [K2HR3](https://k2hr3.antpick.ax/) system.  
Ultimately, the configuration and all packages needed to connect to the **K2HDKC cluster** are installed and configured to automate the management of **K2HDKC slave nodes**.  

The **K2HDKC slave node** in this way can automatically perform processing such as connection/disconnection according to the scale of the K2HDKC server node.  

Thus, it hides the configuration of the K2HDK cluster from the user's program on the **K2HDKC slave node**.  
The user program does not need to be aware of the server node configuration, and the load on developers and operators can be reduced.  

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
