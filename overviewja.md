---
layout: contents
language: ja
title: Overview
short_desc: Database as a Service for K2HDKC
lang_opp_file: overview.html
lang_opp_word: To English
prev_url: 
prev_string: 
top_url: indexja.html
top_string: TOP
next_url: whatnewja.html
next_string: What's new
---

# **K2HDKC DBaaS**
**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[K2HR3](https://k2hr3.antpick.ax/indexja.html)を使い、[OpenStack](https://www.openstack.org/) および [kubernetes](https://kubernetes.io/)と連動して、分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) の環境を構築する**Database as a Service**です。

## 背景
Yahoo! JAPANがオープンソースとして公開する一連のプロダクト群の[AntPickax](https://antpick.ax/indexja.html)は、分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を公開しています。  
この [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を簡単に利用できるように、DBaaS（Database as a Service）として提供することを計画しました。  
そして、公開されている[K2HR3](https://k2hr3.antpick.ax/indexja.html)は、これを実現するために十分な機能を提供しています。  
私たちは、この[K2HR3](https://k2hr3.antpick.ax/indexja.html)を中心に、[OpenStack](https://www.openstack.org/) および [kubernetes](https://kubernetes.io/)と連動して**DBaaS（Database as a Service）**を実現しました。  

**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、以下の[AntPickax](https://antpick.ax/indexja.html)プロダクトを使い、構成されています。

### [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) - K2Hash based Distributed Kvs Cluster
分散KVSであり、**K2HDKC DBaaS**の核となるプロダクトです。
### [CHMPX](https://chmpx.antpick.ax/indexja.html) - Consistent Hashing Mq inProcess data eXchange
ネットワークを跨ぐプロセス間におけるバイナリ通信を行うための通信ミドルウエアであり、[K2HDKC](https://k2hdkc.antpick.ax/indexja.html)が内部で利用します。
### [K2HR3](https://k2hr3.antpick.ax/indexja.html) - K2Hdkc based Resource and Roles and policy Rules
RBAC (Role Based Access Control) システムであり、**K2HDKC DBaaS** で作成されるK2HDKCクラスターの構成を管理します。

# 概要
**K2HDKC DBaaS** (Database as a Service for K2HDKC) が提供する **DBaaS（Database as a Service）** は、以下に示す4つのタイプがあります。  
[OpenStack](https://www.openstack.org/)と連動する **K2HDKC DBaaS** を2つ、[kubernetes](https://kubernetes.io/)と連動するものを2つ提供します。

## [Trove(Trove is Database as a Service for OpenStack) 対応](overview_troveja.html)
[OpenStack](https://www.openstack.org/) のプロダクトである [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) を使った**DBaaS（Database as a Service）**です。  
これは、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove)のひとつのデータベース（分散KVS）として、[K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を組み込み、DBaaSを実現します。  

## [K2HDKC DBaaS CLI（Command Line Interface）](overview_clija.html) for OpenStack
[OpenStack](https://www.openstack.org/)の環境を持っていることを前提とし、**K2HDKC DBaaS CLI（Command Line Interface）**を使って、**DBaaS（Database as a Service）**が実現できます。

## [K2HDKC DBaaS on kubernetes CLI（Command Line Interface）](overview_k8s_clija.html)
すでに利用している[kubernetes](https://kubernetes.io/)クラスターや、`minikube`などの試用環境に、**K2HDKC DBaaS on kubernetes CLI（Command Line Interface）**を使って、**DBaaS（Database as a Service）**が実現できます。  

## [K2HDKC Helm Chart](overview_helm_chartja.html)
すでに利用している[kubernetes](https://kubernetes.io/)クラスターや、`minikube`などの試用環境に、[Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー）に対応した **K2HDKC Helm Chart** を使って、**DBaaS（Database as a Service）** を構築します。  
