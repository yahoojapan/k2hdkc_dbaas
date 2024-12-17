---
layout: contents
language: ja
title: Trove Trial Environment
short_desc: Database as a Service for K2HDKC
lang_opp_file: build.html
lang_opp_word: To English
prev_url: 
prev_string: 
top_url: usage_troveja.html
top_string: Usage DBaaS with Trove
next_url: 
next_string: 
---

# K2HDKC DBaaS with Trove 環境構築
[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove)と連携する**K2HDKC DBaaS with Trove** (Database as a Service for K2HDKC)の環境構築について説明します。
この **K2HDKC DBaaS with Trove** は、[Trove](https://wiki.openstack.org/wiki/Trove) にDatabaseのひとつとして 分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を組み込んだシステムです。  

## 必要となる周辺システム
**K2HDKC DBaaS** の環境を構築するためには、[OpenStack](https://www.openstack.org/) が動作している環境が必要になります。  
また、[OpenStack](https://www.openstack.org/) は、[Trove](https://wiki.openstack.org/wiki/Trove) を組み込み利用します。  

必要となる周辺のシステムを以下に示します。  

### [Trove](https://wiki.openstack.org/wiki/Trove) 環境
[OpenStack](https://www.openstack.org/) の環境を準備し、これに [Trove](https://wiki.openstack.org/wiki/Trove) を組み込んだ環境が必要となります。  
[Trove](https://wiki.openstack.org/wiki/Trove) は、**K2HDKC DBaaS Trove** [リポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_trove)のパッチを適用した状態で起動します。  
そして、**K2HDKC DBaaS Trove** [リポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_trove)で提供するTroveのゲストOSイメージを作成し、K2HDKCサーバーノード用のOSイメージとして登録しておく必要があります。  
また、[OpenStack](https://www.openstack.org/) と [Trove](https://wiki.openstack.org/wiki/Trove) の `stable/2024.1`バージョン以降のために、K2HDKC Trove Dockerイメージも作成し、アクセス可能なDockerレジストリに登録しておく必要があります。

### [K2HR3](https://k2hr3.antpick.ax/indexja.html) システム
**K2HDKC DBaaS** は、バックエンドとして[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムと連携します。  
この[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムは、OpenStackのコンポーネントおよびインスタンス（`Virtual Machine`）からアクセスできるネットワーク環境に準備してください。  

### 動作環境条件
私たちは、**K2HDKC DBaaS Trove**を[RockyLinix 9.x](https://rockylinux.org/)を使い、確認しています。  
また、K2HDKC DBaaS Troveは、OpenStack [stable/2024.1](https://docs.openstack.org/2024.1/index.html) 以降を使います。  
これ以外の環境をお使いの場合、動作しない可能性があります。  
不具合などを見つけた場合は、[Issue](https://github.com/yahoojapan/k2hdkc_dbaas_trove/issues)を送ってください。  

## 試用環境の構築
**K2HDKC DBaaS Trove** は、OpenStackの[DevStack](https://docs.openstack.org/devstack/latest/) をベースとして、**K2HDKC DBaaS Trove**の提供するツールを使って、簡単に試用環境を構築できます。  
[Trove](https://wiki.openstack.org/wiki/Trove) は、そのバージョンに対応した [DevStack](https://docs.openstack.org/devstack/) を使うように設計されており、**K2HDKC DBaaS Trove**も対応したバージョンの[DevStack](https://docs.openstack.org/devstack/) で試用環境を構築します。  

**K2HDKC DBaaS Trove**の提供するツールは、[Trove](https://wiki.openstack.org/wiki/Trove)に独自のコードを組み込み、その試用環境を構築します。  
また、試用環境に必要とされる [K2HR3](https://k2hr3.antpick.ax/indexja.html) バックエンドシステムの構築します。  
このツールは、試用環境に必要とされる専用のゲストOSイメージ、K2HDKC Trove Dockerイメージの作成、登録もできます。  

### 試用環境に必要なシステム
**K2HDKC DBaaS Trove** 試用環境には、16GB程度のメモリ、120GB程度のディスクサイズの環境を準備してください。  
試用環境を構築するためには、[DevStack](https://docs.openstack.org/devstack/latest/)が動作する環境を準備してください。  
準備する環境が、OpenStackで作成されたVirtual Machineなどの場合は、[Nested Virtualization](https://docs.openstack.org/devstack/latest/guides/devstack-with-nested-kvm.html)などを参考にして環境を整えてください。  

### 試用環境の構築
以下に示す手順で、**K2HDKC DBaaS Trove** の環境の構築ができます。  

#### (1) 試用環境用ホスト設定
**K2HDKC DBaaS Trove** の試用環境を構築するホストの環境を整えてください。  
[DevStack](https://docs.openstack.org/devstack/latest/)が動作するための準備をします。  

**K2HDKC DBaaS Trove** の試用環境がPROXYを必要とする場合は、以降の作業を行う前に`HTTP(S)_PROXY`や`NO_PROXY`環境変数を設定してください。

#### (2) **K2HDKC DBaaS Trove** リポジトリの展開
試用環境を構築するために、１台のHOST（もしくは`Virtual Machine`）を準備します。  
（以降の説明で`<hostname or ip address>`と記述された分は、すべてこのHOSTを意味します。）  
試用環境を構築するHOSTに、**K2HDKC DBaaS Trove** [リポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_trove) を展開します。  
```
$ git clone https://github.com/yahoojapan/k2hdkc_dbaas_trove.git
```

#### (3) k2hdkcstack.sh 実行
[k2hdkcstack.sh](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hdkcstack.md) ツールは、**K2HDKC DBaaS Trove** の試用環境を構築するツールです。  
このツールのみを実行することで、**K2HDKC DBaaS Trove** の試用環境を構築できます。  

以下にこのツールを使って、初期化（クリーンアップ）、構築の例を示します。  

##### (3-1) 初期化（クリーンアップ）
すでに試用環境が起動している場合、もしくは構築した試用環境を破棄する場合は、この初期化（クリーンアップ）を実行します。  
```
$ cd buildutils
$ ./k2hdkcstack.sh clean -r -pr
```

##### (3-2) 試用環境構築
以下のコマンドを使って、試用環境を構築します。  
```
$ cd buildutils
$ ./k2hdkcstack.sh start --password <password> --without-docker-image
```

この実行により、**K2HDKC DBaaS Trove** を含む OpenStack + Trove環境が構築されます。  
また、[K2HR3](https://k2hr3.antpick.ax/indexja.html) バックエンドシステムもこの環境内に構築されます。  
**K2HDKC DBaaS Trove**によるK2HDKCクラスター（サーバーノード）を起動するための、ゲストOSイメージも作成、登録されます。  

これにより、**K2HDKC DBaaS Trove**としての必要な環境、コンポーネントが構築できます。  

#### (4) 確認
試用環境が正常に起動された場合、以下のように表示されます。  
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

動作確認をするために、`DevStack(OpenStack) console from the URL` および `K2HR3 Web appliction` にアクセスし、ログインできるか確認してください。  
ログイン時のユーザ名は、`admin`、`trove`、`demo`のいずれかで試します。  

## 補足
### ツール
ツールは、`buildutils`ディレクトリ以下にあります。  
それぞれのツールの目的と、簡単な使い方を説明します。  

#### k2hdkcstack.sh
**K2HDKC DBaaS Trove** 試用環境を構築することを目的としたツールです。  
このツールは、構築と同時に `k2hdkcdockerimage.sh` と `k2hr3setup.sh` を呼び出し、K2HDKC DBaaS Trove Dockerイメージの作成・登録と [K2HR3](https://k2hr3.antpick.ax/indexja.html) バックエンドシステムの構築も行います。  

ツールのオプションおよび利用方法は、[こちら](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hdkcstack.md)を参照してください。  

#### k2hdkcdockerimage.sh
K2HDKC DBaaS Trove Dockerイメージの作成と登録をするツールです。  

**K2HDKC DBaaS Trove** は、K2HDKC クラスターのサーバーノード用と、そのノードのバックアップ用のDockerイメージが必要です。  
このツールは、これらの2つのDockerイメージ（`k2hdkc-trove`、`k2hdkc-trove-backup`）を作成・登録します。  
このツールは、`k2hdkcstack.sh` から呼び出されます。  
また、直接利用することもできます。  

ツールのオプションおよび利用方法は、[こちら](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hdkcdockerimage.md)を参照してください。  

#### k2hr3setup.sh
試用環境のために最小構成の[K2HR3](https://k2hr3.antpick.ax/indexja.html) バックエンドシステムを構築するツールです。  
このツールは`k2hdkcstack.sh` から呼び出されることを想定していますので、直接利用する必要はありません。  

ツールのオプションおよび利用方法は、[こちら](https://github.com/yahoojapan/k2hdkc_dbaas_trove/blob/master/buildutils/README_k2hr3setup.md)を参照してください。  

### K2HDKC DBaaS Troveイメージ
**K2HDKC DBaaS Trove** は、K2HDKC クラスターのサーバーノード用と、そのノードのバックアップ用のDockerイメージが必要です。  

私たちは、これらのDockerイメージを [DockerHub](https://hub.docker.com/) から頒布しています。  
- [k2hdkc-trove](https://hub.docker.com/r/antpickax/k2hdkc-trove)
- [k2hdkc-trove-backup](https://hub.docker.com/r/antpickax/k2hdkc-trove-backup)

このDockerイメージを利用する場合は、`k2hdkcstack.sh` ツールを起動するときに、`--without-docker-image(-nd)`オプションを指定し、Dockerイメージの作成・登録をスキップできます。  
独自のDockerイメージを利用する場合には、`--with-docker-image(-d)`オプションを指定してください。
