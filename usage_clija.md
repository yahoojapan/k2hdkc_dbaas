---
layout: contents
language: ja
title: Usage(CLI)
short_desc: Database as a Service for K2HDKC
lang_opp_file: usage_cli.html
lang_opp_word: To English
prev_url: usageja.html
prev_string: Usage(Trove)
top_url: indexja.html
top_string: TOP
next_url: 
next_string: 
---

# 使い方
**K2HDKC DBaaS CLI** (Command Line Interface)の使い方を説明します。  
**K2HDKC DBaaS CLI**（Command Line Interface）は、[OpenStack](https://www.openstack.org/) のコンポーネントと [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムと連携します。  

**K2HDKC DBaaS CLI**（Command Line Interface）は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のプラグインとして動作します。  

ここでは、**K2HDKC DBaaS CLI** でK2HDKCクラスターの作成、スケール、削除について、また自動化されたK2HDKCスレーブの起動・確認方法について説明します。  

## 1. インストール
**K2HDKC DBaaS CLI**（Command Line Interface）は、[packagecloud.io](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-cli) でパッケージとして提供しています。  
以下でパッケージとしてインストールする場合の説明をします。  
ソースコードを展開して利用する場合は、[k2hdkc_dbaas_cliリポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_cli)を参照してください。  

### 1.1. リポジトリ設定
まず、`packagecloud.io`のリポジトリの設定をします。
```
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.deb.sh | sudo bash
  または
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.rpm.sh | sudo bash
```

### 1.2. インストール
次に、**K2HDKC DBaaS CLI**（Command Line Interface）をインストールします。
```
$ apt install k2hdkc-dbaas-cli
  または
$ yum install k2hdkc-dbaas-cli
```
_各コマンドはお使いのOS環境に応じたパッケージマネージャーのものをお使いください。_  

**K2HDKC DBaaS CLI**（Command Line Interface）は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のプラグインです。  
よって、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)もインストールされます。  

### 1.3. 確認
以下のコマンドを実行して、正常にインストールされているか確認してください。
```
$ k2hr3 --version

K2HR3 Command Line Interface - 1.0.1(d12a87d)

Copyright 2021 Yahoo! Japan Corporation.

K2HR3 is K2hdkc based Resource and Roles and policy Rules,
gathers common management information for the cloud.
K2HR3 can dynamically manage information as "who", "what",
"operate". These are stored as roles, resources, policies
in K2hdkc, and the client system can dynamically read and
modify these information.

This software is released under the MIT License.

-----------------------------------------------------------
K2HDKC DBaaS Command Line Interface - 1.0.0(26cdbcc)

Copyright 2021 Yahoo! Japan Corporation.

The K2HDKC DBaaS CLI (Command Line Interface of Database as a
Service for K2HDKC) is a tool for building a K2HDKC cluster
in conjunction with K2HR3.
The Trove version of K2HDKC DBaaS is available, but this
K2HDKC DBaaS CLI allows you to build K2HDKC clusters without
the need for a Trove system.
With the basic components of OpenStack and the K2HR3 system
that works with it, you can easily build a K2HD KC cluster
using the K2HDKC DBaaS CLI.

This software is released under the MIT License.
```
**K2HDKC DBaaS CLI**と、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のバージョン番号が表示されていれば問題ありません。

## 2. K2HDKC DBaaS CLIコマンド
**K2HDKC DBaaS CLI**（Command Line Interface）は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のプラグインであり、**K2HDKC DBaaS CLI** を実行するには `k2hr3` プログラムを使います。  
**K2HDKC DBaaS CLI**としての機能は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のひとつのサブコマンドである `database`で提供されます。  

**K2HDKC DBaaS CLI**のサブコマンドの機能は、以下のようにして確認できます。
```
$ k2hr3 database --help
```
各`database`サブコマンドの使い方は、ヘルプを参照してください。

## 3. K2HDKC DBaaS CLI 環境設定
**K2HDKC DBaaS CLI** は、[K2HR3](https://k2hr3.antpick.ax/indexja.html) および [OpenStack](https://www.openstack.org/) と連動して動作します。  

それぞれのシステムは、構築済みであることが前提となっています。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html) の構築については、[こちら](https://k2hr3.antpick.ax/setup_trialja.html)を参照してください。  
予め[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、[OpenStack](https://www.openstack.org/) と連携するように構築してください。  

**K2HDKC DBaaS CLI** コマンドは、[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムの[K2HR3 REST API](https://k2hr3.antpick.ax/apija.html)と、[OpenStack](https://www.openstack.org/)の **Identity** のURIにアクセスします。  
コマンド実行毎に、これらのURIを指定することができますが、予めURIを**K2HR3 CLIのコンフィグレーション**として設定することで、この操作を省略できます。  
以下のようにして各URIを設定します。  
```
$ k2hr3 config set K2HR3CLI_API_URI https://localhost:3000
Succeed : Set "K2HR3CLI_API_URI: https://localhost:3000"

$ k2hr3 config set K2HR3CLI_OPENSTACK_IDENTITY_URI https://localhost/identity
Succeed : Set "K2HR3CLI_OPENSTACK_IDENTITY_URI: https://localhost/identity"
```
_https://localhost:3000と、https://localhost/identityは、それぞれ K2HR3 REST API のURIと、OpenStack IdentityのURIに置き換えてください。_

以降は、これらのURIが設定されている前提で説明してます。

## 4. K2HDKCクラスターの構築
**K2HDKCクラスター** (サーバーノード)を構築する手順を説明します。

まず、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが、[OpenStack](https://www.openstack.org/) と連携しており、以下の共通のユーザ名、テナント（プロジェクト）であることを前提とします。  
- ユーザ名  
`demo`
- テナント（プロジェクト）名  
`demo`

### 4.1. K2HR3 トークン
**K2HDKC クラスター**を構築するために、まず[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムのScopedトークンが必要となります。  
また、[OpenStack](https://www.openstack.org/) のScopedトークンも必要となります。  
これらのトークンは、以降で説明するコマンド実行毎に指定することができますが、予め**K2HR3 CLIのコンフィグレーション**として設定することで、この操作を省略できます。  
よって以下の説明では、**K2HR3 CLIのコンフィグレーション**にトークンを保管するオプションを含んだ事例を示しています。

#### 4.1.1. OpenStackトークン
まず、OpenStackのScopedトークンを取得し、**K2HR3 CLIのコンフィグレーション**に保管します。  

```
$ k2hr3 database openstack token --op_user demo --op_tenant demo --interactive --saveconfig
OpenStack User passphrase: ********
gAAAAABgYV-h9MUf_gmfKRjx5cOGilOzg7KCSjccDwoPsYYTIao8gyA_VAozAFRVnconTsYQNTxYe01OWD8bmi_zcoeFzTEmqalt0INtHgP4-XXXXdVKWPNJ7o41NMCk95Oz6f3h6IJZPjYeMItymRBclLXKF4NykELxwgBl6ZqK-Z5laTRY5Njw_v-6ulhR9EzPyGP_gDqU
```
上記では、`-\-interactive`オプションを指定することで、パスフレーズをコマンドラインで入力せず、対話式に入力しています。  

#### 4.1.2. K2HR3トークン
次に、上記で取得したOpenStackのトークンを使い、K2HR3のUnscopedおよびScopedトークンを取得し、**K2HR3 CLIのコンフィグレーション**に保管します。  
K2HR3のScopedトークンは、ユーザクレデンシャルを指定して取得することもできます。  
詳しくは、[こちら](https://k2hr3.antpick.ax/cli_tokenja.html)を参照してください。  

```
$ k2hr3 token create token_optoken --tenant demo --saveconfig
gAAAAABgYWFJDRoCI0R96YxUkbjE0A7b6OLIoZtkdC36yMvfkSha_1-zxOAmLYYYYWGJhk1O2ZV9FElRyCLvc5_8VNTJfh1HKk2ayANoDiv6LFk6O2DE40QXDR2yed70akOAUZNcJ_Dasbkt6OeSCMX6619OZ6fbpeYsingBC3-fY2XfPwQmc2QA4pFlzwsa34Di532MxtST
```

### 4.2. K2HDKCクラスター設定
**K2HDKC クラスター**のサーバーノードを作成する前に、**K2HDKC クラスター**の情報を[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムに設定します。  

作成する**K2HDKC クラスター**を`mycluster`として、以下のコマンドを実行します。  
```
$ k2hr3 database create mycluster --dbaas_create_user k2hdkcuser
Succeed : Phase : Create "mycluster" Resource
Succeed : Phase : Create "mycluster/server" Resource
Succeed : Phase : Create "mycluster/slave" Resource
Succeed : Phase : Create "mycluster" Policy
Succeed : Phase : Create "mycluster" Role
Succeed : Phase : Create "mycluster/server" Role
Succeed : Phase : Create "mycluster/slave" Role
Succeed : Registration of cluster "mycluster" with K2HR3 is complete
```
上記の`k2hdkcuser`は、**K2HDKC クラスター**のサーバーノードで実行される[k2hdkc](https://k2hdkc.antpick.ax/indexja.html)と[chmpx](https://chmpx.antpick.ax/indexja.html)プロセスの実行ユーザです。  
このコマンドの実行により、[K2HR3](https://k2hr3.antpick.ax/indexja.html)のリソース（RESOURCE）、ポリシー（POLICY-RULE）、ロール（ROLE）が適切に設定されます。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)に設定された情報を確認するには、[こちら](https://k2hr3.antpick.ax/usage_appja.html)の操作方法を使って、Web上で確認できます。  

### 4.3. OpenStackの情報
**K2HDKC クラスター**のサーバーノード（`Virtual Machine`）は、連携している[OpenStack](https://www.openstack.org/)のインスタンスとして起動します。  
[OpenStack](https://www.openstack.org/)のインスタンスを起動するために、イメージ名（もしくはID）と、フレーバー名（もしくはID）が必要となります。  
以下のコマンドを使い、利用できるイメージ名（もしくはID）と、フレーバー名（もしくはID）を確認できます。  
```
$ k2hr3 database list images --json
[
    {
        "name": "my-ubuntu-2004-image",
        "id": "59aa4ab3-7e89-42fb-83f9-093d3c83737e"
    },
    {
        "name": "my-centos-8-image",
        "id": "fd4b4411-c6b8-4f0a-95d7-fe5a9dfbca5d"
    },
    {
        "name": "cirros-0.4.0-x86_64-disk",
        "id": "075035da-db6d-4b1c-bc8b-7570c505d618"
    }
]

$ k2hr3 database list flavors --json
[
    {
        "name": "m1.tiny",
        "id": "1"
    },
    {
        "name": "m1.small",
        "id": "2"
    },
    {
        "name": "m1.medium",
        "id": "3"
    },
    {
        "name": "m1.large",
        "id": "4"
    },
    {
        "name": "m1.xlarge",
        "id": "5"
    },
    {
        "name": "cirros256",
        "id": "c1"
    },
    {
        "name": "ds512M",
        "id": "d1"
    },
    {
        "name": "ds1G",
        "id": "d2"
    },
    {
        "name": "ds2G",
        "id": "d3"
    },
    {
        "name": "ds4G",
        "id": "d4"
    }
]
```
次に説明する**K2HDKC クラスター**のサーバーノード（`Virtual Machine`）の起動では、イメージ名、フレーバー名を指定できます。  
しかし、イメージIDおよびフレーバーIDを指定した方が、良好なパフォーマンスで起動できます。  

### 4.4. K2HDKCサーバーノード
**K2HDKC クラスター**を構築の最後に、K2HDKCサーバーノード（`Virtual Machine`）を起動します。  
以下のコマンドを使って、起動します。  
前述したように、イメージIDおよびフレーバーIDを指定して起動します。  

```
$ k2hr3 database add host server mycluster myserver1 --op_keypair demo --op_flavor_id d2 --op_image_id 59aa4ab3-7e89-42fb-83f9-093d3c83737e
Succeed : Add server host(myserver1 - "99c0d9e5-a050-45f8-829c-fee6975310ad") for mycluster cluster.
```
`--op_keypair demo`は、予め[OpenStack](https://www.openstack.org/)に設定しておいた`demo`ユーザのキーペアです。  

上記により、**K2HDKC クラスター** `mycluster`のサーバーノードとして、`myserver1`ホストが起動できます。  
複数の**K2HDKC クラスター**のサーバーノードを起動するには、上記のコマンドをホスト名を変更しながら繰り返します。  

## 5. スレーブノードの起動
上記までで、**K2HDKC クラスター**のサーバーノードが起動出来ました。  
ここでは、そのサーバーノードに接続するスレーブノードを起動します。  
以下のようにコマンドを実行します。  

```
$ k2hr3 database add host slave mycluster myslave1 --op_keypair demo --op_flavor_id d2 --op_image_id 59aa4ab3-7e89-42fb-83f9-093d3c83737e
Succeed : Add slave host(myslave1 - "0e358601-1a0f-4e43-a18a-28e7a9d14813") for mycluster cluster.
```
上記により、スレーブノードとして`myslave1`が起動できます。  

## 6. K2HDKCクラスターのノード破棄
起動した**K2HDKC クラスター**のサーバーノードおよびスレーブノードの破棄ができます。  
以下のコマンドにて実行できます。

```
$ k2hr3 database delete host mycluster myserver4
Succeed : Delete host myserver4 from mycluster cluster(OpenStack and K2HR3).
```
このコマンドは、サーバーノード、スレーブノードの区別はありません。  
いずれのノードであってもホスト名を指定するだけで破棄できます。  

## 7. K2HDKCクラスターの破棄
**K2HDKC クラスター**の全サーバーノードおよびスレーブノード、設定情報のすべてを破棄できます。  
以下のコマンドにて実行できます。

```
$ k2hr3 database delete cluster mycluster
[IMPORTANT CONFIRM] You will lose all data/server in your cluster, Do you still want to run it? (y/n) y
[NOTICE] Delete all of the cluster configuration, data, cluster hosts, and so on.
Succeed : Delete all mycluster cluster(OpenStack and K2HR3).
```
**K2HDKC クラスター**の削除の場合には、確認のためのプロンプトが表示されます。  
このプロンプトを表示したくない場合には、`--yes(-y)`オプションを指定して、実行してください。

## 8. まとめ
上記、1から6までの操作で、[OpenStack](https://www.openstack.org/)に**K2HDKC クラスター**を簡単に構築できます。  
必要となるのは、[OpenStack](https://www.openstack.org/)に連動する[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムだけです。  
