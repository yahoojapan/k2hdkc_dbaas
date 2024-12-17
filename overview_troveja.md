---
layout: contents
language: ja
title: Overview DBaaS with Trove
short_desc: Database as a Service for K2HDKC
lang_opp_file: overview_trove.html
lang_opp_word: To English
prev_url: 
prev_string: 
top_url: overviewja.html
top_string: Overview
next_url: overview_clija.html
next_string: Overview DBaaS CLI
---

# K2HDKC DBaaS with Trove 概要

**K2HDKC DBaaS** (Database as a Service for K2HDKC) を[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove)の一つのDatabaseとして提供します。  
**K2HDKC DBaaS with Trove** は、[OpenStack](https://www.openstack.org/) コンポーネント および [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) と連携し、**DBaaS（Database as a Service）**としての機能を提供します。  

![K2HDKC DBaaS with Trove Overview](images/overview.png)

**K2HDKC DBaaS** でK2HDKCクラスター構築などの操作は、すべてDashboard（Trove Dashboard）もしくは、Trove CLI（openstackコマンド）から実行できます。  
K2HDKCクラスターの構築、削除、クラスターへサーバーノードの追加・削除（スケール）、バックアップ、リストアの操作ができます。  
また、ユーザが **K2HDKC DBaaS** で構築したK2HDKCクラスターへ簡単に接続し、利用できるようにするため、K2HDKCスレーブノードの起動、自動コンフィグレーションをサポートします。  

# K2HDKC DBaaS with Trove の構成

**K2HDKC DBaaS with Trove** の大まかなシステムの説明をします。  

## OpenStack コンポーネント
**K2HDKC DBaaS** には、OpenStackのコンポーネントが必要となります。  
OpenStackの各コンポーネントおよび全体の構築はユーザが行います。  
既存のOpenStackに、**K2HDKC DBaaS** を組み込むことも可能です。  
Trove は、OpenStack コンポーネントのひとつであり、**K2HDKC DBaaS** は、TroveのDatabaseのひとつとして組み込まれています。  
つまり、このTroveのタイプの**K2HDKC DBaaS**は、TroveのDatabaseの種類にK2HDKCを拡張したシステムです。  
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

_K2HDKCサーバープロセス群は、インスタンス（`Virtual Machine`）内でDockerコンテナーとして起動されます。（K2HDKC DBaaS Trove バージョン1.0.2以降、OpenStack Trove stable/2024.1以降）_

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

