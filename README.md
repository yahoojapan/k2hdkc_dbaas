K2HDKC DBaaS
-----
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://raw.githubusercontent.com/yahoojapan/k2hdkc_dbaas/master/LICENSE)
[![GitHub forks](https://img.shields.io/github/forks/yahoojapan/k2hdkc_dbaas.svg)](https://github.com/yahoojapan/k2hdkc_dbaas/network)
[![GitHub stars](https://img.shields.io/github/stars/yahoojapan/k2hdkc_dbaas.svg)](https://github.com/yahoojapan/k2hdkc_dbaas/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/yahoojapan/k2hdkc_dbaas.svg)](https://github.com/yahoojapan/k2hdkc_dbaas/issues)

## **K2HDKC** **DBaaS** based on **Trove**
![K2HDKC DBaaS](https://dbaas.k2hdkc.antpick.ax/images/top_k2hdkc_dbaas.png)

## Overview
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that is provided by [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) which incorporates [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) as one of the Database.  
K2HDKC DBaaS works with OpenStack components to provide Database as a Service functionality.  

Users can easily launch, scale, backup, and restore K2HDKC clusters through the Trove Dashboard(GUI) and through the CLI provided by Trove(openstack CLI).  

Detailed documentation for K2HDKC DBaaS can be found [here](https://dbaas.k2hdkc.antpick.ax/).

## K2HKDC DBaaS system
K2HDKC DBaaS provides its functionality through Trove as a panel(feature) of OpenStack.  
And the [K2HR3](https://k2hr3.antpick.ax/) system is used as the back end as an RBAC(Role Base Access Control) system dedicated to K2HDKC DBaaS.  
Normally, users do not need to use the K2HR3 system directly, and the function as DBaaS uses Trove Dashboard(or Trove CLI).  

The overall system overview diagram is shown below.  
![K2HDKC DBaaS system](https://dbaas.k2hdkc.antpick.ax/images/overview.png)  

## Trial
For the K2HDKC DBaaS experience, you can build a minimum K2HDKC DBaaS system.  
This minimum system has all the features of K2HDKC DBaaS.  
So you can use it to try out all the features provided by K2HDKC DBaaS.  

This minimum system(trial environment) is very easy to build by simply running the script provided by this repository.  
For how to use it, refer to the [Build document](https://dbaas.k2hdkc.antpick.ax/build.html).  

## Usage
See [Usage document](https://dbaas.k2hdkc.antpick.ax/usage.html) for the features provided by K2HDKC DBaaS and how to use them.  
This document describes all usage, including how to use K2HDKC DBaaS to create a K2HDKC cluster, how to launch a K2HDKC slave node, and more.  

Let's get started.  

## Documents
[K2HDKC DBaaS Document](https://dbaas.k2hdkc.antpick.ax/index.html)  
[Github wiki page](https://github.com/yahoojapan/k2hdkc_dbaas/wiki)

[About k2hdkc Document](https://k2hdkc.antpick.ax/index.html)  
[About chmpx Document](https://chmpx.antpick.ax/index.html)  
[About k2hr3 Document](https://k2hr3.antpick.ax/index.html)  

[About AntPickax](https://antpick.ax/)  

## Repositories
[k2hdkc](https://github.com/yahoojapan/k2hdkc)  
[chmpx](https://github.com/yahoojapan/chmpx)  
[k2hr3](https://github.com/yahoojapan/k2hr3)  
[k2hr3_app](https://github.com/yahoojapan/k2hr3_app)  
[k2hr3_api](https://github.com/yahoojapan/k2hr3_api)  

## Packages
[k2hdkc(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc)  
[chmpx(packagecloud.io)](https://packagecloud.io/app/antpickax/stable/search?q=chmpx)  
[k2hr3-app(npm packages)](https://www.npmjs.com/package/k2hr3-app)  
[k2hr3-api(npm packages)](https://www.npmjs.com/package/k2hr3-api)  

### License
This software is released under the 2.0 version of the Apache License, see the license file.

### AntPickax
K2HDKC DBaaS is one of [AntPickax](https://antpick.ax/) products.

Copyright(C) 2020 Yahoo Japan Corporation.
