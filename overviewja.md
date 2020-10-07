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
**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) にDatabaseのひとつとして 分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を利用できるようにした、**Database as a Service**です。

## 背景
Yahoo! JAPANがオープンソースとして公開する一連のプロダクト群の[AntPickax](https://antpick.ax/indexja.html)は、分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を公開しています。  
この [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を簡単に利用できるように、DBaaS（Database as a Service）として提供することを計画しました。  
また、公開されている[K2HR3](https://k2hr3.antpick.ax/indexja.html)は、これを実現するために十分な機能を提供しています。  
そして、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) のひとつのデータベース（分散KVS）として、[K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を組み込み、DBaaSを実現しました。  

**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) と以下の[AntPickax](https://antpick.ax/indexja.html)プロダクトを使い、構成されています。

### [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) - K2Hash based Distributed Kvs Cluster
分散KVSであり、**K2HDKC DBaaS**の核となるプロダクトです。
### [CHMPX](https://chmpx.antpick.ax/indexja.html) - Consistent Hashing Mq inProcess data eXchange
ネットワークを跨ぐプロセス間におけるバイナリ通信を行うための通信ミドルウエアであり、[K2HDKC](https://k2hdkc.antpick.ax/indexja.html)が内部で利用します。
### [K2HR3](https://k2hr3.antpick.ax/indexja.html) - K2Hdkc based Resource and Roles and policy Rules
RBAC (Role Based Access Control) システムであり、**K2HDKC DBaaS** で作成されるK2HDKCクラスターの構成を管理します。

# 概要
**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) をベースとし、[OpenStack](https://www.openstack.org/) のコンポーネントと連携します。  

![K2HDKC DBaaS Overview](images/overview.png)

**K2HDKC DBaaS** でK2HDKCクラスター構築などの操作は、すべてDashboard（Trove Dashboard）もしくは、Trove CLI（openstackコマンド）から実行できます。  
K2HDKCクラスターの構築、削除、クラスターへサーバーノードの追加・削除（スケール）、バックアップ、リストアの操作ができます。  
また、ユーザが **K2HDKC DBaaS** で構築したK2HDKCクラスターへ簡単に接続し、利用できるようにするため、K2HDKCスレーブノードの起動、自動コンフィグレーションをサポートします。  

**K2HDKC DBaaS** の大まかなシステムの説明をします。  

## OpenStack コンポーネント
**K2HDKC DBaaS** には、OpenStackのコンポーネントが必要となります。  
OpenStackの各コンポーネントおよび全体の構築はユーザが行います。  
既存のOpenStackに、**K2HDKC DBaaS** を組み込むことも可能です。  
Trove は、OpenStack コンポーネントのひとつであり、**K2HDKC DBaaS** は、TroveのDatabaseのひとつとして組み込まれています。  
つまり、**K2HDKC DBaaS**は、TroveのDatabaseの種類にK2HDKCを拡張したシステムです。  
**K2HDKC DBaaS**の基本的な仕様は、すべてTroveに従っており、Troveの操作でDBaaSとしての操作・動作を行えます。  

## K2HR3 システム
**K2HDKC DBaaS**は、[AntPickax](https://antpick.ax/indexja.html)プロダクトの一つである [K2HR3](https://k2hr3.antpick.ax/indexja.html) システムを必要とします。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムとTroveが連携し、DBaaS機能を実現しています。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)は、OpenStackと連携できるように設計されており、バックエンドのシステムとしてTroveと連携します。  

[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、OpenStackのコンポーネントやインスタンス（`Virtual Machine`）からアクセスできるネットワーク環境に構築する必要があります。  
例えば、ネットワーク内で到達できる環境であればよいため、**K2HDKC DBaaS**と連携するOpenStackが作成するインスタンス（`Virtual Machine`）の中で起動することもできます。  

## K2HDKC クラスター
これは、**K2HDKC DBaaS** が構築し、起動するK2HDKCのクラスターです。  
OpenStackの管理する複数のインスタンス（`Virtual Machine`）でK2HDKCサーバーノードが起動され、クラスターを構成します。  
**K2HDKC DBaaS** の機能は、このK2HDKCクラスターの構築、破棄、制御（スケール、データマージ）することです。  

## K2HDKC スレーブノード
**K2HDKC DBaaS**により作成されたK2HDKCクラスター（サーバーノード）に接続するノード（クライアント）のことです。

![K2HDKC DBaaS Slave Overview](images/overview_slave.png)

K2HDKCスレーブノードは、手動で設定し、起動できます。  
しかし、**K2HDKC DBaaS** の機能を使うことにより、自動的なコンフィグレーションをサポートできます。  
このためには、**K2HDKC DBaaS** と連携しているOpenStackのインスタンス（`Virtual Machine`）をK2HDKCのスレーブノードとして起動します。
このインスタンス（`Virtual Machine`）を起動するときに、[K2HR3](https://k2hr3.antpick.ax/indexja.html)が提供する `User Data Script for OpenStack`データを使用します。  
起動後のインスタンス（`Virtual Machine`）は、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムと連動します。  
その結果、K2HDKCクラスターに接続するために必要なK2HDKC設定や、K2HDKCスレーブノードに必要なすべてのパッケージがインストール・設定され、K2HDKCスレーブノードの管理の自動化ができます。  

このように起動したK2HDKCスレーブノードは、K2HDKCサーバーノードのスケールに応じて、接続・切断などの処理を自動化することができます。  
そして、K2HDKCスレーブノード上のユーザのプログラムから、K2HDKクラスターの構成を隠蔽し、ユーザのプログラムはサーバーノードの構成を意識する必要がなくなり、開発者・運用者の負荷を低減できます。