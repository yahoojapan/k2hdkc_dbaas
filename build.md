---
layout: contents
language: en-us
title: Build a trial environment
short_desc: Database as a Service for K2HDKC
lang_opp_file: buildja.html
lang_opp_word: To Japanese
prev_url: whatnew.html
prev_string: What's new
top_url: index.html
top_string: TOP
next_url: usage.html
next_string: Usage
---

# Build a trial environment
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that is provided by [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) which incorporates [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/indexja.html) as one of the Database.  

This document describes how to build a trial environment for **K2HDKC DBaaS**.  

## Required systems
To build the **K2HDKC DBaaS** system environment, [OpenStack](https://www.openstack.org/) must be running.  
And you need to setup [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) system to that [OpenStack](https://www.openstack.org/) system.  

The required systems are shown below.  

### [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) system
You need an environment that prepares [OpenStack](https://www.openstack.org/) system and incorporates [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) into it.  
And you must patch this [Trove](https://wiki.openstack.org/wiki/Trove) with **K2HDKC DBaaS** [repository](https://github.com/yahoojapan/k2hdkc_dbaas) code.  
Then you need to create a `Trove guest OS image` with the **K2HDKC DBaaS** [repository](https://github.com/yahoojapan/k2hdkc_dbaas) script and register it in [OpenStack](https://www.openstack.org/) as the OS image for the **K2HDKC server node**.  

### [K2HR3](https://k2hr3.antpick.ax/) system
**K2HDKC DBaaS** works with the [K2HR3](https://k2hr3.antpick.ax/) system as a backend.  
Prepare this [K2HR3](https://k2hr3.antpick.ax/) system in a network accessible from [OpenStack](https://www.openstack.org/) components and instances(`Virtual Machine`).  

### Environment conditions
We are testing **K2HDKC DBaaS** on [CentOS 8.2](https://wiki.centos.org/Manuals/ReleaseNotes/CentOS8.2004).  
And **K2HDKC DBaaS** uses OpenStack [Ussuri](https://docs.openstack.org/ussuri/).  
If you are using any other environment, it may not work.  
If you find any problems, please send [Issue](https://github.com/yahoojapan/k2hdkc_dbaas/issues).  

## Trial environment
**K2HDKC DBaaS** can easily build a trial environment by indirectly using OpenStack's [DevStack](https://docs.openstack.org/devstack/latest/) tool.  
[Trove](https://wiki.openstack.org/wiki/Trove) is designed to use [DevStack](https://docs.openstack.org/devstack/latest/), so **K2HDKC DBaaS** can use [DevStack](https://docs.openstack.org/devstack/latest/) to build a trial environment.  

We provide a **patch** for incorporating **K2HDKC DBaaS** into [Trove](https://wiki.openstack.org/wiki/Trove) and a **shell script** for building a trial environment which has the [K2HR3](https://k2hr3.antpick.ax/) system for backend.  

### Required systems for a trial environment
For **K2HDKC DBaaS** trial environment, prepare a host machine with a memory of about 16GB and a disk size of about 120GB.  
_Strictly speaking, probably it also works in a lower performance host environment._  
Please prepare the environment where [DevStack](https://docs.openstack.org/devstack/latest/) works.  

### Build a trial environment
You can build the **K2HDKC DBaaS** trial environment by following the steps below.  

#### (1) Clone **K2HDKC DBaaS** repository
Prepare one host machine(or `Virtual Machine`) to build a trial environment.  
_Everything written as `<hostname or ip address>` in the following explanation means this host._  

Clone **K2HDKC DBaaS** [repository](https://github.com/yahoojapan/k2hdkc_dbaas) to the host that builds the trial environment.  

```
$ git clone https://github.com/yahoojapan/k2hdkc_dbaas.git
```

#### (2) Host environment settings
In the host that builds the trial environment, the controller node of OpenStack including the Trove function is operated.  
Prepare the host of the trial environment so that these processes can operate.  
```
$ cd k2hdkc_dbaas/utils
$ ./custom_devstack_setup_1.sh
```
When the script execution is complete, the host machine will be restarted automatically.  

#### (3) Build an OpenStack controller node
Start all OpenStack controller nodes including Trove which contains the **K2HDKC DBaaS** functionality.  
During this process, a `Trove guest OS image` for **K2HDKC DBaaS** is created and automatically registered as an OS image in Trove and OpenStack.  
```
$ cd k2hdkc_dbaas/utils
$ sudo install -o stack -g stack *.sh -v /opt/stack
$ sudo su - stack
$ ./custom_devstack_setup_2.sh
```
After the script completes successfully, all OpenStack controller nodes that incorporate Trove including **K2HDKC DBaaS** functionality are up.  

You can verify all OpenStack controller node startup by accessing the Dashboard(which has a built-in Trove panel).  
```
URL: http://<hostname or ip address>/
```
At this step, **K2HDKC DBaaS** will not work because we have not yet built the [K2HR3](https://k2hr3.antpick.ax/) system.  

#### (4) Build [K2HR3](https://k2hr3.antpick.ax/) system
Finally, build the [K2HR3](https://k2hr3.antpick.ax/) system that is used as the backend for **K2HDKC DBaaS**.  
[K2HR3](https://k2hr3.antpick.ax/) system is built to work in one instance(`Virtual Machine`) of OpenStack built above(3).  
```
$ sudo su - stack
$ ./k2hr3_pack_setup.sh
```
After the script completes successfully, you can access the `K2HR3 Web Application` via the host machine that built the trial environment.  
```
URL: http://<hostname or ip address>:28080/
```

#### (5) Verification
If you can successfully access the `Trove Dashboard` shown in (3) and the `K2HR3 Web Application` shown in (4), the trial environment has been **successfully built**.  
How to use **K2HDKC DBaaS** will be explained in the next chapter.
