---
layout: contents
language: ja
title: Build a trial environment
short_desc: Database as a Service for K2HDKC
lang_opp_file: build.html
lang_opp_word: To English
prev_url: whatnewja.html
prev_string: What's new
top_url: indexja.html
top_string: TOP
next_url: usageja.html
next_string: Usage
---

# 環境構築
**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) にDatabaseのひとつとして 分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を組み込んだシステムです。  

このドキュメントでは、**K2HDKC DBaaS** の構築方法について説明します。  

## 必要となる周辺システム
**K2HDKC DBaaS** の環境を構築するためには、[OpenStack](https://www.openstack.org/) が動作している環境が必要になります。  
また、[OpenStack](https://www.openstack.org/) は、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) を組み込み利用します。  

必要となる周辺のシステムを以下に示します。  

### [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) 環境
[OpenStack](https://www.openstack.org/) の環境を準備し、これに [Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) を組み込んだ環境が必要となります。  
[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) は、**K2HDKC DBaaS** [リポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas)のパッチを適用した状態で起動します。  
そして、**K2HDKC DBaaS** [リポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas)で提供するTroveのゲストOSイメージを作成し、K2HDKCサーバーノード用のOSイメージとして登録しておく必要があります。  

### [K2HR3](https://k2hr3.antpick.ax/indexja.html) システム
**K2HDKC DBaaS** は、バックエンドとして[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムと連携します。  
この[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムは、OpenStackのコンポーネントおよびインスタンス（`Virtual Machine`）からアクセスできるネットワーク環境に準備してください。  

### 動作環境条件
私たちは、**K2HDKC DBaaS**を[CentOS 8.2](https://wiki.centos.org/Manuals/ReleaseNotes/CentOS8.2004)を使い、確認しています。  
また、K2HDKC DBaaSは、OpenStack [Ussuri](https://docs.openstack.org/ussuri/)を使います。  
これ以外の環境をお使いの場合、動作しない可能性があります。  
不具合などを見つけた場合は、[Issue](https://github.com/yahoojapan/k2hdkc_dbaas/issues)を送ってください。  

## 試用環境の構築
**K2HDKC DBaaS** は、OpenStackの[DevStack](https://docs.openstack.org/devstack/latest/) を使い、簡単に試用環境を構築できます。  
[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) は、[DevStack](https://docs.openstack.org/devstack/latest/) を使うように設計されており、**K2HDKC DBaaS**も同様に[DevStack](https://docs.openstack.org/devstack/latest/) を使い、試用環境を構築できます。  

[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove) に **K2HDKC DBaaS** を組み込むためのパッチと、バックエンドで利用する[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムの試用環境構築のためのスクリプトを提供します。  

### 試用環境に必要なシステム
**K2HDKC DBaaS** 試用環境には、16GB程度のメモリ、120GB程度のディスクサイズの環境を準備してください。  
試用環境を構築するためには、[DevStack](https://docs.openstack.org/devstack/latest/)が動作する環境を準備してください。  
準備する環境が、OpenStackで作成されたVirtual Machineなどの場合は、[Nested Virtualization](https://docs.openstack.org/devstack/latest/guides/devstack-with-nested-kvm.html)などを参考にして環境を整えてください。  

### 試用環境の構築
以下に示す手順で、**K2HDKC DBaaS** の環境の構築ができます。  

#### (1) **K2HDKC DBaaS** リポジトリの展開
試用環境を構築するために、１台のHOST（もしくは`Virtual Machine`）を準備します。  
（以降の説明で`<hostname or ip address>`と記述された分は、すべてこのHOSTを意味します。）  
試用環境を構築するHOSTに、**K2HDKC DBaaS** [リポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas) を展開します。  
```
$ git clone https://github.com/yahoojapan/k2hdkc_dbaas.git
```

#### (2) OpenStackコントローラノードのHOST設定
試用環境を構築するHOSTでは、Troveの機能を含むOpenStackのコントローラノードを動作させます。  
試用環境のHOSTをこれらのプロセスが動作できるように環境を整えます。  
```
$ cd k2hdkc_dbaas/utils
$ ./custom_devstack_setup_1.sh
```
スクリプトを実行後、試用環境のHOSTは自動的に再起動されます。  

#### (3) OpenStackコントローラノードの構築
**K2HDKC DBaaS** の機能を含むTroveを組み込んだOpenStackコントローラノードを起動します。  
この過程で**K2HDKC DBaaS**のための`TroveゲストOSイメージ`が作成され、自動的にTroveおよびOpenStackにOSイメージとして登録されます。  
```
$ cd k2hdkc_dbaas/utils
$ sudo install -o stack -g stack *.sh -v /opt/stack
$ sudo su - stack
$ ./custom_devstack_setup_2.sh
```
スクリプトの実行完了後、**K2HDKC DBaaS** の機能を含むTroveを組み込んだOpenStackコントローラノードのすべてが起動しています。  

OpenStackコントローラノードの起動は、Dashboard（Troveパネルが組み込まれています）にアクセスして確認できます。  
```
URL: http://<hostname or ip address>/
```
この段階では、まだ[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムを構築していないため、**K2HDKC DBaaS**は動作しません。  

#### (4) [K2HR3](https://k2hr3.antpick.ax/indexja.html) システム構築
最後に、**K2HDKC DBaaS** のバックエンドとして動作する[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムを構築します。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムは、上記で構築したOpenStackの払い出す1つのインスタンス（`Virtual Machine`）で動作するように構築されます。  
```
$ sudo su - stack
$ ./k2hr3_devpack_setup.sh
```
このスクリプトは、途中であなたにブラウザでアクセスするためのhostnameもしくはIPアドレスを確認します。  
表示されているhostnameやIPアドレスと異なる値を使う場合には、この確認で修正することができます。  

スクリプトの実行完了後、試用環境を構築したHOSTを経由して、K2HR3 Web Applicationにアクセスすることができます。  

以下のように確認することができます。  
```
URL: http://<hostname or ip address>:28080/
```

#### (5) 確認
(3)で示したTrove Dashboardおよび、(4)で示すK2HR3 Web Applicationにアクセスできれば、試用環境の構築は完了です。  
試用環境を含むK2HDKC DBaaSの使い方は、次章の**K2HDKC DBaaS** の使い方で説明します。  

