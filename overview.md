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
**K2HDKC DBaaS** (Database as a Service for K2HDKC) is a **Database as a Service** that uses [K2HR3](https://k2hr3.antpick.ax/) and works with [OpenStack](https://www.openstack.org/) and [kubernetes](https://kubernetes.io/) to build a [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/index.html) Cluster for distributed KVS.

## Background
Yahoo! JAPAN publishes some products as [AntPickax](https://antpick.ax/) as Open Source Software(OSS).  
We planned to provide one of them, [K2HDKC(K2Hash based Distributed Kvs Cluster)](https://k2hdkc.antpick.ax/) as **DBaaS(Database as a Service)** so that anyone can easily use it.  
And the publicly available [K2HR3(K2Hdkc based Resource and Roles and policy Rules)](https://k2hr3.antpick.ax/) offers enough features to make this happen.  
We have built ** DBaaS (Database as a Service)** in conjunction with [OpenStack](https://www.openstack.org/) and [kubernetes](https://kubernetes.io/), centering on this [K2HR3(K2Hdkc based Resource and Roles and policy Rules)](https://k2hr3.antpick.ax/).  

**K2HDKC DBaaS** (Database as a Service for K2HDKC) is configured using the following products which is provided by [AntPickax](https://antpick.ax/index.html).  

### [K2HDKC](https://k2hdkc.antpick.ax/) - K2Hash based Distributed Kvs Cluster
This product is distributed KVS(Key Value Store) clustering system and the core product of **K2HDKC DBaaS**.
### [CHMPX](https://chmpx.antpick.ax/) - Consistent Hashing Mq inProcess data eXchange
This product is communication middleware over the network for sending binary data and an important component responsible for [K2HDKC](https://k2hdkc.antpick.ax/) communication.
### [K2HR3](https://k2hr3.antpick.ax/) - K2Hdkc based Resource and Roles and policy Rules
This is extended RBAC (Role Based Access Control) system, and this system manages the configuration of the **K2HDKC cluster** as a backend for **K2HDKC DBaaS**.

# Overview
There are four types of **DBaaS(Database as a Service)** provided by "K2HDKC DBaaS** (Database as a Service for K2HDKC) as shown below.
We provide two **K2HDKC DBaaS** types that cooperate with [OpenStack](https://www.openstack.org/) and two types that cooperate with [kubernetes](https://kubernetes.io/).

## [With Trove(Trove is Database as a Service for OpenStack)](overview_trove.html)
This is **DBaaS(Database as a Service)** using [Trove](https://wiki.openstack.org/wiki/Trove) which is a product of [OpenStack](https://www.openstack.org/).  
It incorporates [K2HDKC](https://k2hdkc.antpick.ax/) (Distributed KVS) as one of Trove's databases to realize **DBaaS(Database as a Service)**.  

## [K2HDKC DBaaS CLI(Command Line Interface)](overview_cli.html) for OpenStack
If you have an existing [OpenStack](https://www.openstack.org/) environment, this **K2HDKC DBaaS CLI(Command Line Interface)** allows you to implement **DBaaS(Database as a Service)** without any changes.

## [K2HDKC DBaaS on kubernetes CLI(Command Line Interface)](overview_k8s_cli.html)
If you are using [kubernetes](https://kubernetes.io/) cluster or trial environment such as `minikube`, this **K2HDKC DBaaS on kubernetes CLI(Command Line Interface)** allows you to implement **DBaaS(Database as a Service)** without any changes.

## [K2HDKC Helm Chart](overview_helm_chart.html)
If you are using [kubernetes](https://kubernetes.io/) cluster or trial environment such as `minikube`, you can install(build) **DBaaS(Database as a Service)** by using [Helm(The package manager for Kubernetes)](https://helm.sh/) with **K2HDKC Helm Chart**.

### RANCHER
[K2HDKC Helm Chart](overview_helm_chart.html) can also be used as **RANCHER Helm Chart** and can be registered in the [RANCHER](https://rancher.com/) repository.  
You can easily build up a K2HDKC cluster using [RANCHER](https://rancher.com/) to [K2HDKC Helm Chart](overview_helm_chart.html).  
