K2HDKC DBaaS
------------
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://raw.githubusercontent.com/yahoojapan/k2hdkc_dbaas/master/LICENSE)
[![GitHub forks](https://img.shields.io/github/forks/yahoojapan/k2hdkc_dbaas.svg)](https://github.com/yahoojapan/k2hdkc_dbaas/network)
[![GitHub stars](https://img.shields.io/github/stars/yahoojapan/k2hdkc_dbaas.svg)](https://github.com/yahoojapan/k2hdkc_dbaas/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/yahoojapan/k2hdkc_dbaas.svg)](https://github.com/yahoojapan/k2hdkc_dbaas/issues)

## About **K2HDKC** **DBaaS**

![K2HDKC DBaaS](https://dbaas.k2hdkc.antpick.ax/images/top_k2hdkc_dbaas.png)

### K2HDKC DBaaS Overview
**K2HDKC DBaaS** (DataBase as a Service of K2HDKC) is a basic system that provides [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) as a service.  
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that uses [K2HR3](https://k2hr3.antpick.ax/) and works with [OpenStack](https://www.openstack.org/) and [kubernetes](https://kubernetes.io/) to build a [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) Cluster for distributed KVS.  
Users can easily launch, scale, back up, and restore **K2HDKC** clusters as **K2HDKC DBaaS**.  

Detailed documentation for K2HDKC DBaaS can be found [here](https://dbaas.k2hdkc.antpick.ax/).  

#### Background
Yahoo! JAPAN publishes some products as [AntPickax](https://antpick.ax/) as Open Source Software(OSS).  
We planned to provide one of them, [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/) as **DBaaS(Database as a Service)** so that anyone can easily use it.  
And the publicly available [K2HR3(K2Hdkc based Resource and Roles and policy Rules)](https://k2hr3.antpick.ax/) offers enough features to make this happen.  
We have built **DBaaS**(Database as a Service) in conjunction with [OpenStack](https://www.openstack.org/) and [kubernetes](https://kubernetes.io/), centering on this [K2HR3(K2Hdkc based Resource and Roles and policy Rules)](https://k2hr3.antpick.ax/).  

### Components for K2HKDC DBaaS system
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is configured using the following products which is provided by [AntPickax](https://antpick.ax/index.html).  

- [K2HDKC](https://k2hdkc.antpick.ax/) - K2Hash based Distributed Kvs Cluster  
This product is distributed KVS(Key Value Store) clustering system and the core product of **K2HDKC DBaaS**.
- [CHMPX](https://chmpx.antpick.ax/) - Consistent Hashing Mq inProcess data eXchange  
This product is communication middleware over the network for sending binary data and an important component responsible for [K2HDKC](https://k2hdkc.antpick.ax/) communication.
- [K2HR3](https://k2hr3.antpick.ax/) - K2Hdkc based Resource and Roles and policy Rules  
This is extended RBAC (Role Based Access Control) system, and this system manages the configuration of the **K2HDKC cluster** as a backend for **K2HDKC DBaaS**.

### K2HKDC DBaaS types
There are four types of **DBaaS** (Database as a Service) provided by **K2HDKC DBaaS** (Database as a Service for K2HDKC) as shown below.  
We provide two K2HDKC DBaaS types that cooperate with OpenStack and two types that cooperate with kubernetes.  

#### With Trove(Trove is Database as a Service for OpenStack)
This is DBaaS(Database as a Service) using Trove which is a product of OpenStack.  
It incorporates K2HDKC (Distributed KVS) as one of Trove’s databases to realize DBaaS(Database as a Service).  
The source code is [k2hdkc_dbaas_trove](https://github.com/yahoojapan/k2hdkc_dbaas_trove).

#### K2HDKC DBaaS CLI(Command Line Interface) for OpenStack
If you have an existing OpenStack environment, this K2HDKC DBaaS CLI(Command Line Interface) allows you to implement DBaaS(Database as a Service) without any changes.  
The source code is [k2hdkc_dbaas_cli](https://github.com/yahoojapan/k2hdkc_dbaas_cli).

#### K2HDKC DBaaS on kubernetes CLI(Command Line Interface)
If you are using kubernetes cluster or trial environment such as minikube, this K2HDKC DBaaS on kubernetes CLI(Command Line Interface) allows you to implement DBaaS(Database as a Service) without any changes.  
The source code is [k2hdkc_dbaas_k8s_cli](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli).

#### K2HDKC Helm Chart
If you are using kubernetes cluster or trial environment such as minikube, you can install(build) DBaaS(Database as a Service) by using Helm(The package manager for Kubernetes) with K2HDKC Helm Chart.  
The source code is [k2hdkc_helm_chart](https://github.com/yahoojapan/k2hdkc_helm_chart).

## Documents
[K2HDKC DBaaS Document](https://dbaas.k2hdkc.antpick.ax/index.html)  
[Github wiki page](https://github.com/yahoojapan/k2hdkc_dbaas/wiki)  

[About k2hdkc Document](https://k2hdkc.antpick.ax/index.html)  
[About chmpx Document](https://chmpx.antpick.ax/index.html)  
[About k2hr3 Document](https://k2hr3.antpick.ax/index.html)  

[About AntPickax](https://antpick.ax/)  

## Repositories
[k2hdkc_dbaas_trove](https://github.com/yahoojapan/k2hdkc_dbaas_trove)  
[k2hdkc_dbaas_cli](https://github.com/yahoojapan/k2hdkc_dbaas_cli)  
[k2hdkc_dbaas_k8s_cli](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli)  
[k2hdkc_dbaas_override_conf](https://github.com/yahoojapan/k2hdkc_dbaas_override_conf)  

[k2hdkc](https://github.com/yahoojapan/k2hdkc)  
[chmpx](https://github.com/yahoojapan/chmpx)  

[k2hr3](https://github.com/yahoojapan/k2hr3)  
[k2hr3_app](https://github.com/yahoojapan/k2hr3_app)  
[k2hr3_api](https://github.com/yahoojapan/k2hr3_api)  
[k2hr3_cli](https://github.com/yahoojapan/k2hr3_cli)  
[k2hr3_get_resource](https://github.com/yahoojapan/k2hr3_get_resource)  

## Packages
[k2hdkc-trove(Docker image)](https://hub.docker.com/r/antpickax/k2hdkc-trove)  
[k2hdkc-trove-backup(Docker image)](https://hub.docker.com/r/antpickax/k2hdkc-trove-backup)  
[k2hdkc-dbaas-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-cli)  
[k2hdkc-dbaas-k8s-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-k8s-cli)  
[k2hdkc-dbaas-override-conf(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-override-conf)  

[k2hdkc(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc)  
[chmpx(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=chmpx)  

[k2hr3-app(npm packages)](https://www.npmjs.com/package/k2hr3-app)  
[k2hr3-api(npm packages)](https://www.npmjs.com/package/k2hr3-api)  
[k2hr3-cli(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hr3-cli)  
[k2hr3-get-resource(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hr3-get-resource)  

### License
This software is released under the 2.0 version of the Apache License, see the license file.

### AntPickax
K2HDKC DBaaS is one of [AntPickax](https://antpick.ax/) products.

Copyright(C) 2020 Yahoo Japan Corporation.
