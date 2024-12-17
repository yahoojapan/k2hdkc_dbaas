---
layout: contents
language: en-us
title: Trove Trial Environment
short_desc: Database as a Service for K2HDKC
lang_opp_file: buildja.html
lang_opp_word: To Japanese
prev_url: 
prev_string: 
top_url: usage_trove.html
top_string: Usage DBaaS with Trove
next_url: 
next_string: 
---

# Build a trial environment
Describes how to build an environment for **K2HDKC DBaaS with Trove** (Database as a Service for K2HDKC) that works with [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove).  
This **K2HDKC DBaaS with Trove** is a system that incorporates [K2HDKC](https://k2hdkc.antpick.ax/) as a distributed KVS into one of [Trove](https://wiki.openstack.org/wiki/Trove) Databases.  

## Required systems
To build the **K2HDKC DBaaS** system environment, [OpenStack](https://www.openstack.org/) must be running.  
And you need to setup [Trove](https://wiki.openstack.org/wiki/Trove) system to that [OpenStack](https://www.openstack.org/) system.  

The required systems are shown below.  

### [Trove](https://wiki.openstack.org/wiki/Trove) system
You need an environment that prepares [OpenStack](https://www.openstack.org/) system and incorporates [Trove](https://wiki.openstack.org/wiki/Trove) into it.  
And you must patch this [Trove](https://wiki.openstack.org/wiki/Trove) with **K2HDKC DBaaS Trove** [repository](https://github.com/yahoojapan/k2hdkc_dbaas_trove) code.  
Then you need to create a `Trove guest OS image` with the **K2HDKC DBaaS Trove** [repository](https://github.com/yahoojapan/k2hdkc_dbaas_trove) script and register it in [OpenStack](https://www.openstack.org/) as the OS image for the **K2HDKC server node**.  
And you need to create a `K2HDKC Trove Docker images` with the **K2HDKC DBaaS Trove** [repository](https://github.com/yahoojapan/k2hdkc_dbaas_trove) script and register it in Docker registory which is allowed to access.  

### [K2HR3](https://k2hr3.antpick.ax/) system
**K2HDKC DBaaS** works with the [K2HR3](https://k2hr3.antpick.ax/) system as a backend.  
Prepare this [K2HR3](https://k2hr3.antpick.ax/) system in a network accessible from [OpenStack](https://www.openstack.org/) components and instances(`Virtual Machine`).  

### Environment conditions
We are testing **K2HDKC DBaaS Trove** on [RockyLinix 9.x](https://rockylinux.org/).  
And **K2HDKC DBaaS Trove** uses OpenStack [stable/2024.1](https://docs.openstack.org/2024.1/index.html) or later.  
If you are using any other environment, it may not work.  
If you find any problems, please send [Issue](https://github.com/yahoojapan/k2hdkc_dbaas_trove/issues).  

## Trial environment
**K2HDKC DBaaS Trove** allows you to easily build a trial environment using the tools provided by **K2HDKC DBaaS Trove** based on OpenStack's [DevStack](https://docs.openstack.org/devstack/latest/).  
[Trove](https://wiki.openstack.org/wiki/Trove) is designed to use the [DevStack](https://docs.openstack.org/devstack/) that corresponds to its version, and **K2HDKC DBaaS Trove** also creates a trial environment with the corresponding version of [DevStack](https://docs.openstack.org/devstack/).

The tool provided by **K2HDKC DBaaS Trove** incorporates our code into [Trove](https://wiki.openstack.org/wiki/Trove) and builds the trial environment.  
It also builds the [K2HR3](https://k2hr3.antpick.ax/indexja.html) backend system required for the trial environment.  
This tool can also create and register the dedicated guest OS image and K2HDKC Trove Docker image required for the trial environment.  

### Required systems for a trial environment
For **K2HDKC DBaaS Trove** trial environment, prepare a host machine with a memory of about 16GB and a disk size of about 120GB.  
_Strictly speaking, probably it also works in a lower performance host environment._  
To build a trial environment, please prepare an environment in which [DevStack](https://docs.openstack.org/devstack/latest/) operates.  
If the environment to be prepared is a `Virtual Machine` created with OpenStack, etc., refer to [Nested Virtualization](https://docs.openstack.org/devstack/latest/guides/devstack-with-nested-kvm.html) etc. to prepare the environment.  

### Build a trial environment
You can build the **K2HDKC DBaaS Trove** trial environment by following the steps below.  

#### (1) Host settings for trial environment
Prepare the host environment for building the trial environment for **K2HDKC DBaaS Trove**.  
Prepare for [DevStack](https://docs.openstack.org/devstack/latest/) to run.  

If the trial environment for **K2HDKC DBaaS Trove** requires a PROXY, set the `HTTP(S)_PROXY` or `NO_PROXY` environment variable before proceeding with the following steps.  

#### (2) Clone **K2HDKC DBaaS Trove** repository
Prepare one host machine(or `Virtual Machine`) to build a trial environment.  
_Everything written as `<hostname or ip address>` in the following explanation means this host._  

Clone **K2HDKC DBaaS Trove** [repository](https://github.com/yahoojapan/k2hdkc_dbaas_trove) to the host that builds the trial environment.  

```
$ git clone https://github.com/yahoojapan/k2hdkc_dbaas_trove.git
```

#### (3) Run k2hdkcstack.sh
The [k2hdkcstack.sh](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hdkcstack.md) tool is a tool to build a trial environment for **K2HDKC DBaaS Trove**.  
You can build a trial environment for **K2HDKC DBaaS Trove** by running only this tool.  

Below is an example of initialization (cleanup) and construction using this tool.  

##### (3-1) Initialization (cleanup)
If the trial environment is already running, or if you want to discard the trial environment you created, perform this initialization (cleanup).  
```
$ cd buildutils
$ ./k2hdkcstack.sh clean -r -pr
```

##### (3-2) Creating a trial environment
Use the following command to create a trial environment.  
```
$ cd buildutils
$ ./k2hdkcstack.sh start --password password --without-docker-image
```

This execution will create an OpenStack + Trove environment that includes **K2HDKC DBaaS Trove**.  
The [K2HR3](https://k2hr3.antpick.ax/indexja.html) backend system will also be created within this environment.  
A guest OS image will also be created and registered to start the K2HDKC cluster (server node) using **K2HDKC DBaaS Trove**.  

This will create the necessary environment and components for **K2HDKC DBaaS Trove**.

#### (4) Verification
If the trial environment is started successfully, the following will be displayed.  
```
---------------------------------------------------------------------
[TITLE] Summary : K2HDKC DBaaS Trove
---------------------------------------------------------------------
[SUCCESS] Started devstack (2024-XX-XX-XX:XX:XX)
    You can access the DevStack(OpenStack) console from the URL:
        http://devstack.localhost/
    Initial administrator users log in with admin : ********.

    K2HDKC Trove docker image:        .../k2hdkc-trove:1.0.2-alpine
    K2HDKC Trove backup docker image: .../k2hdkc-trove-backup:1.0.2-alpine

[SUCCESS] Finished k2hr3setup.sh process without error. (2024-XX-XX-XX:XX:XX)
 Base host(openstack trove)  :
 K2HR3 System(instance name) : k2hdkc-dbaas-k2hr3
       APP local port        : 28080
       API local port        : 18080
 K2HR3 Web appliction        : http://XX.XX.XX.XX:8080/
 K2HR3 REST API              : http://XX.XX.XX.XX:18080/
```

To check the operation, access the `DevStack (OpenStack) console from the URL` and the `K2HR3 Web application` and check if you can log in.  
When logging in, try using the username `admin`, `trove`, or `demo`.  

## Notes

### Tools
The tools are located under the `buildutils` directory.  
The purpose of each tool and a simple usage are explained below.  

#### k2hdkcstack.sh
This tool is intended to build a trial environment for **K2HDKC DBaaS Trove**.  
This tool calls `k2hdkcdockerimage.sh` and `k2hr3setup.sh` at the same time as building, and also creates and registers the K2HDKC DBaaS Trove Docker image and builds the [K2HR3](https://k2hr3.antpick.ax/indexja.html) backend system.  

For tool options and usage, please refer to [here](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hdkcstack.md).  

#### k2hdkcdockerimage.sh
This is a tool to create and register K2HDKC DBaaS Trove Docker images.  

**K2HDKC DBaaS Trove** requires Docker images for the server nodes of the K2HDKC cluster and for the backup of those nodes.  
This tool creates and registers these two Docker images (`k2hdkc-trove`, `k2hdkc-trove-backup`).
This tool is called from `k2hdkcstack.sh`.  
You can also use it directly.  

For the options and usage of the tool, please see [here](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hdkcdockerimage.md).  

#### k2hr3setup.sh
This is a tool to build a minimal [K2HR3](https://k2hr3.antpick.ax/indexja.html) backend system for a trial environment.  
This tool is intended to be called from `k2hdkcstack.sh`, so there is no need to use it directly.  

See [here](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hr3setup.md) for tool options and usage.  

### K2HDKC DBaaS Trove image
**K2HDKC DBaaS Trove** requires Docker images for the server nodes of the K2HDKC cluster and for backing up those nodes.  

We distribute these Docker images from [DockerHub](https://hub.docker.com/).  
- [k2hdkc-trove](https://hub.docker.com/r/antpickax/k2hdkc-trove)
- [k2hdkc-trove-backup](https://hub.docker.com/r/antpickax/k2hdkc-trove-backup)

If you use this Docker image, you can skip creating and registering the Docker image by specifying the `--without-docker-image(-nd)` option when starting the `k2hdkcstack.sh` tool.  
If you use your own Docker image, specify the `--with-docker-image(-d)` option.
