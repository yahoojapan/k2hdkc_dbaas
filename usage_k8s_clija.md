---
layout: contents
language: ja
title: Usage DBaaS on k8s CLI
short_desc: Database as a Service for K2HDKC
lang_opp_file: usage_k8s_cli.html
lang_opp_word: To English
prev_url: usage_clija.html
prev_string: Usage DBaaS CLI
top_url: usageja.html
top_string: Usage
next_url: usage_helm_chartja.html
next_string: Usage K2HDKC Helm Chart
---

# 使い方 - K2HDKC DBaaS on kubernetes CLI
**K2HDKC DBaaS on kubernetes CLI** (Command Line Interface)の使い方を説明します。  
**K2HDKC DBaaS on kubernetes CLI**は、[kubernetes](https://kubernetes.io/) と [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムと連携します。  

**K2HDKC DBaaS on kubernetes CLI**は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のプラグインとして動作します。  

**K2HDKC DBaaS on kubernetes CLI** でK2HDKCクラスターの構築・操作をするためには、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが必要となります。  
この[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、[kubernetes](https://kubernetes.io/)クラスター内に構築する必要があります。  
**K2HDKC DBaaS on kubernetes CLI** は、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの構築・削除もできます。  

[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの構築・操作、およびK2HDKCクラスターの作成・削除などの操作について、以下に説明します。  

以降のコマンド例は、`local kubernetes cluster`として[minikube](https://minikube.sigs.k8s.io/docs/)を構築し、**K2HDKC DBaaS on kubernetes CLI** をその[kubernetes](https://kubernetes.io/)クラスターで実行した例です。
簡単に試すために、[minikube](https://minikube.sigs.k8s.io/docs/)をインストールし、**K2HDKC DBaaS on kubernetes CLI**を実行できます。

## K2HDKC DBaaS on kubernetes CLIの準備
**K2HDKC DBaaS on kubernetes CLI**は、[packagecloud.io](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-k8s-cli) でパッケージとして提供しています。  
以下でパッケージとしてインストールする場合の説明をします。  
ソースコードを展開して利用する場合は、[k2hdkc_dbaas_k8s_cliリポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli)を参照してください。  

### リポジトリ設定
まず、`packagecloud.io`のリポジトリの設定をします。
```
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.deb.sh | sudo bash
  または
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.rpm.sh | sudo bash
```

### インストール
次に、**K2HDKC DBaaS on kubernetes CLI**をインストールします。
```
$ apt install k2hdkc-dbaas-k8s-cli
  または
$ yum install k2hdkc-dbaas-k8s-cli
```
_各コマンドはお使いのOS環境に応じたパッケージマネージャーのものをお使いください。_  

**K2HDKC DBaaS on kubernetes CLI**は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のプラグインです。  
よって、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)もインストールされます。  

### 確認
以下のコマンドを実行して、正常にインストールされているか確認してください。
```
$ k2hr3 --version

K2HR3 Command Line Interface - 1.0.4(2c3f45a)

Copyright 2021 Yahoo Japan Corporation.

K2HR3 is K2hdkc based Resource and Roles and policy Rules,
gathers common management information for the cloud.
K2HR3 can dynamically manage information as "who", "what",
"operate". These are stored as roles, resources, policies
in K2hdkc, and the client system can dynamically read and
modify these information.

This software is released under the MIT License.

-----------------------------------------------------------
K2HDKC DBaaS on kubernetes Command Line Interface - 1.0.0(3541210)

Copyright 2021 Yahoo Japan Corporation.

The K2HDKC DBaaS K8S CLI (Command Line Interface of Database as a
Service for K2HDKC) is a tool for building a K2HDKC cluster in
conjunction with K2HR3.
K2HDKC DBaaS K8S can build a dedicated K2HR3 system in a Kubernetes
cluster and build a K2HDKC cluster that works with it.
With the basic components of Kubernetes system that works with it,
you can easily build a K2HDKC cluster on Kubernetes cluster using
the K2HDKC DBaaS K8S CLI.

This software is released under the MIT License.
```

**K2HDKC DBaaS on kubernetes CLI**と、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のバージョン番号、クレジットが表示されていれば問題ありません。

## K2HDKC DBaaS on kubernetes CLIコマンド
**K2HDKC DBaaS on kubernetes CLI**は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のプラグインであり、**K2HDKC DBaaS on kubernetes CLI** を実行するには `k2hr3` プログラムを使います。  
**K2HDKC DBaaS on kubernetes CLI**としての機能は、[K2HR3 CLI](https://k2hr3.antpick.ax/clija.html)のサブコマンドである `database-k8s`で提供されます。  

**K2HDKC DBaaS on kubernetes CLI**のサブコマンドの機能は、以下のようにして確認できます。
```
$ k2hr3 database-k8s --help
```
各`database-k8s` サブコマンドの使い方は、ヘルプを参照してください。

## K2HR3システムの構築
K2HDKCクラスターを[kubernetes](https://kubernetes.io/)に構築するために使われる[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを構築する方法を説明します。  
この[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、K2HDKC DBaaSを構築するのと同じ[kubernetes](https://kubernetes.io/)クラスターに構築します。  

[kubernetes](https://kubernetes.io/)クラスターの中に複数のK2HDKCクラスターを構築する場合であっても、1つの[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムで動作します。
つまり、1つの[kubernetes](https://kubernetes.io/)クラスターに対して、1つの[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムで十分です。
（なお、複数の[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを構築しても問題ありません。）

現時点で、**K2HDKC DBaaS on kubernetes CLI**を使ってK2HDKCクラスターを構築する場合、その[kubernetes](https://kubernetes.io/)の認証システムは、[OpenID Connect](https://openid.net/connect/)のみサポートします。

[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを構築する例を以下に示します。  
```
$ k2hr3 database-k8s k2hr3 create --minikube --k8s_namespace default --k8s_domain svc.cluster.local --oidc_client_secret bwlztjm4gx56rzs6u7da5gbuf2ayiozbnd7f1zg56ia7f35i --oidc_client_id my-minikube --oidc_issuer_url https://oidc.dbaas.k2hdkc.antpick.ax/dex --oidc_username_key special-username-key --oidc_cookiename id_token --oidc_cookie_expire 120 --k2hr3api_nodeport_num 32043 --k2hr3app_nodeport_num 32443 --nodehost_ips 192.168.1.5
Created : K2HR3 API/APP NodePorts(Cluster IP).
Checked : All certificates.
Created : The prpduction json file for K2HR3 API.
Created : The prpduction json file for K2HR3 APP.
Created : The kustomization.yaml for K2HR3 system.
Created : The yaml files for K2HDKC, K2HR3 API, K2HR3 APP Pods, and ServiceAccount(SA).
Created : All Pods, configMap, Secret, and ServiceAccount(SA) for K2HR3 system.
K2HR3 system Information

[K2HDKC DBaaS K8S : K2HR3 APP/API information]

* CA certificate file
    /home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/ca.crt

* K2HR3 API URL
    Pods:       https://pod-r3api-[0-1].svc-r3api.default.svc.cluster.local:443
    Pods(RR):   https://svc-r3api.default.svc.cluster.local:443
    Cluster:    https://10.100.200.120:8443
    Endpoint:   https://cli.k8s.dbaas.k2hdkc.antpick.ax:32043

* K2HR3 APP URL
    Cluster:    https://10.100.120.200:8443
    Endpoint:   https://cli.k8s.dbaas.k2hdkc.antpick.ax:32443

Saved : The information for K2HR3 system to the configuration file(k2hr3.config)
Succeed : Succeed starting the K2HR3 system
```

[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを構築するには、`k2hr3 database-k8s k2hr3 create` コマンドを実行します。  
このコマンド実行が成功したら、実行結果に表示されている`K2HR3 APP URL`の`Endpoint`にブラウザでアクセスしてください。  
[K2HR3 APP(Webアプリケーション)](https://k2hr3.antpick.ax/usage_app_commonja.html)が表示されるはずです。  

上記の例で指定したオプションを説明します。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、[kubernetes](https://kubernetes.io/)クラスターと同じ[OpenID Connect](https://openid.net/connect/)を使うため、予め[OpenID Connect](https://openid.net/connect/)の設定（情報）は準備してください。  

##### --k8s_namespace <namespace>  
[kubernetes](https://kubernetes.io/)クラスターで使う`NameSpace`を指定します。  
省略された場合は、`default`を使います。
##### --k8s_domain <domain>  
[kubernetes](https://kubernetes.io/)クラスターの`ドメイン名`を指定します。  
省略された場合は、`svc.cluster.local`を使います。
##### --minikube  
[kubernetes](https://kubernetes.io/)クラスターが[minikube](https://minikube.sigs.k8s.io/docs/)で構築されている場合に指定するオプションです。
##### --oidc_client_secret <string>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使う[OpenID Connect](https://openid.net/connect/)の`Secret`を指定します。
##### --oidc_client_id <string>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使う[OpenID Connect](https://openid.net/connect/)の`Client id`を指定します。
##### --oidc_issuer_url <url>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使う[OpenID Connect](https://openid.net/connect/)の`Issuer URL`を指定します。
##### --oidc_username_key <string>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使う[OpenID Connect](https://openid.net/connect/)の返すトークンに、ユーザ名を示すキーが存在する場合は、そのキー文字列を指定します。
ユーザ名を示すキーが存在しない場合は、このオプションは指定する必要はありません。
##### --oidc_cookiename <string>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使う[OpenID Connect](https://openid.net/connect/)の返すトークンを、**K2HR3 APP**(Webアプリケーション)に引き渡すために使うCookie名を指定します。
##### --oidc_cookie_expire <number>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使う[OpenID Connect](https://openid.net/connect/)の返すトークンを、**K2HR3 APP**(Webアプリケーション)に引き渡すために使うCookieの有効期限を秒数で指定します。
##### --k2hr3api_nodeport_num <number>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの**K2HR3 API**が使うポート番号を指定します。  
デフォルトでは、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは`NodePort`で構築されるようになっており、**K2HR3 API**が使うポート番号は自動で設定されます。  
自動で設定せず、ポート番号を指定する場合に、このオプションを指定します。
##### --k2hr3app_nodeport_num <number>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの**K2HR3 APP**(Webアプリケーション)が使うポート番号を指定します。  
デフォルトでは、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは`NodePort`で構築されるようになっており、**K2HR3 API**が使うポート番号は自動で設定されます。  
自動で設定せず、ポート番号を指定する場合に、このオプションを指定します。  
[OpenID Connect](https://openid.net/connect/)からリダイレクトされるURLを固定するために、自動ではなくポート番号を指定する必要がありますので、このオプションは指定するようにしてください。
##### --nodehost_ips <ip,ip...>  
[kubernetes](https://kubernetes.io/)クラスターの各NodeのIPアドレスを列挙します。  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの証明書（自己署名）を作成するときに使われます。  
自己署名証明書を使わない場合、もしくは[minikube](https://minikube.sigs.k8s.io/docs/)を使わない場合には、指定する必要はありません。  

## K2HDKCクラスター準備
K2HDKCクラスターを作成する準備をします。
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムに、構築するK2HDKCクラスターの情報をセットアップします。

以下のようにセットアップコマンドを実行します。
```
$ k2hr3 database-k8s k2hdkc setup mycluster --k8s_namespace default --k8s_domain svc.cluster.local --unscopedtoken 8855f196137d6a946eb926496cba3e02d50eb44a119dc70c06c48f55f2734e63
Created : The configuration template file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc.ini") for "mycluster" K2HDKC Cluster
Setup : The K2HR3 Resource "mycluster" for "mycluster" K2HDKC cluster.
Setup : The K2HR3 Resource "mycluster/server" for "mycluster" K2HDKC cluster.
Setup : The K2HR3 Resource "mycluster/slave" for "mycluster" K2HDKC cluster.
Setup : The K2HR3 Policy "mycluster" for "mycluster" K2HDKC cluster.
Setup : The K2HR3 Role "mycluster" for "mycluster" K2HDKC cluster.
Setup : The K2HR3 Role "mycluster/server" for "mycluster" K2HDKC cluster.
Setup : The K2HR3 Role "mycluster/slave" for "mycluster" K2HDKC cluster.
Setup : The Role Token for "mycluster" K2HDKC cluster.
Saved : The configuration("k2hdkc.config") for "mycluster" K2HDKC cluster.
Succeed : Succeed initializing K2HR3 role/policy/resource for K2HDKC DBaaS K8S cluster.
```

K2HDKCクラスターの情報をセットアップするには、`k2hr3 database-k8s k2hdkc setup` コマンドを実行します。  
このコマンドにより、構築するK2HDKCクラスターの情報が、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムに登録されます。  
この内容は、**K2HR3 APP**(Webアプリケーション)などから確認することができます。  

上記の例で指定したオプションを説明します。  

##### <cluster name>  
作成するK2HDKCクラスターのベース名を指定します。  
上記の例では、`mycluster`と指定しています。
##### --k8s_namespace <namespace>  
[kubernetes](https://kubernetes.io/)クラスターで使う`NameSpace`を指定します。  
省略された場合は、`default`を使います。
##### --k8s_domain <domain>  
[kubernetes](https://kubernetes.io/)クラスターの`ドメイン名`を指定します。  
省略された場合は、`svc.cluster.local`を使います。
##### --unscopedtoken <token>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムにログインするための、`Unscoped Token`を指定します。  
この値は、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムにログインし、[ユーザアカウント情報のダイアログ](https://k2hr3.antpick.ax/usage_app_commonja.html)で確認できます。  

## K2HDKCクラスター構築
次に、K2HDKCクラスターを構築します。

以下のようにコマンドを実行します。
```
$ k2hr3 database-k8s k2hdkc create mycluster --k8s_namespace default --k8s_domain svc.cluster.local --server_count 2 --slave_count 2 --server_port 8020 --server_control_port 8021 --slave_control_port 8022
Created : The all certificates for "mycluster" K2HDKC cluster.
Created : The kustomization file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-kustomization.yaml") for "mycluster" K2HDKC cluster.
Created : The symbolic file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/kustomization.yaml") to the kustomization file for "mycluster" K2HDKC cluster.
Created : The K2HDKC server yaml file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-server.yaml.") to the kustomization file for "mycluster" K2HDKC cluster.
Created : The K2HDKC slave yaml file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-slave.yaml.") to the kustomization file for "mycluster" K2HDKC cluster.
Created : The configMap and Secrets from kustomization.yaml for "mycluster" K2HDKC cluster.
Created(Run) : The K2HDKC Servers from "/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-server.yaml" for "mycluster" K2HDKC cluster.
Created(Run) : The K2HDKC Slaves from "/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-k2hdkc-slave.yaml" for "mycluster" K2HDKC cluster.
Saved : The configuration("k2hdkc.config") for "mycluster" K2HDKC cluster.
Succeed : Succeed creating(applying) K2HDKC DBaaS K8S Cluster.
```

K2HDKCクラスターを構築するには、`k2hr3 database-k8s k2hdkc create` コマンドを実行します。  
このコマンドにより、K2HDKCクラスターが指定されたノード数で構築されます。  

上記の例で指定したオプションを説明します。  

##### <cluster name>  
作成するK2HDKCクラスターのベース名を指定します。  
上記の例では、`mycluster`と指定しています。
##### --k8s_namespace <namespace>  
[kubernetes](https://kubernetes.io/)クラスターで使う`NameSpace`を指定します。  
省略された場合は、`default`を使います。
##### --k8s_domain <domain>  
[kubernetes](https://kubernetes.io/)クラスターの`ドメイン名`を指定します。  
省略された場合は、`svc.cluster.local`を使います。
##### --server_count <count>  
構築するK2HDKCクラスターのサーバーノード数を指定します。  
省略した場合は、`2`です。
##### --slave_count <count>  
構築するK2HDKCクラスターのスレーブノード数を指定します。  
省略した場合は、`2`です。
##### --server_port <port number>  
構築するK2HDKCクラスターのサーバーノードの内部ポート番号を指定します。  
省略した場合は、`8020`です。
##### --server_control_port <port number>  
構築するK2HDKCクラスターのサーバーノードの内部制御ポート番号を指定します。  
省略した場合は、`8021`です。
##### --slave_control_port <port number>  
構築するK2HDKCクラスターのスレーブノードの内部ポート番号を指定します。  
省略した場合は、`8022`です。

## K2HDKCクラスターのスケール
K2HDKCクラスターの構成ノードをスケールイン・アウトできます。  

以下のようにコマンドを実行します。  
```
$ k2hr3 database-k8s k2hdkc scale mycluster --k8s_namespace default --k8s_domain svc.cluster.local --server_count 3 --slave_count 3
Created : The kustomization file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/dbaas-kustomization.yaml") for "mycluster" K2HDKC cluster.
Created : The symbolic file("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster/kustomization.yaml") to the kustomization file for "mycluster" K2HDKC cluster.
Applied : The configMap and Secrets from kustomization.yaml for "mycluster" K2HDKC cluster.
Applied : The K2HDKC Servers statefulset("svrpod-mycluster") to set replicas("3")
Saved : The configuration("k2hdkc.config") for "mycluster" K2HDKC cluster servers.
Applied : The K2HDKC Slaves statefulset("slvpod-mycluster") to set replicas("3")
Saved : The configuration("k2hdkc.config") for "mycluster" K2HDKC cluster slaves.
Succeed : Succeed scaling K2HDKC DBaaS K8S Cluster.
```

K2HDKCクラスターをスケールするには、`k2hr3 database-k8s k2hdkc scale` コマンドを実行します。  
このコマンドにより、K2HDKCクラスターが指定されたノード数でスケールイン・アウトされます。  
このコマンドを使わず、[kubectl](https://kubernetes.io/ja/docs/reference/kubectl/overview/)を使うこともできます。（例： `kubectl scale --replicas=<count> ...`）  

上記の例で指定したオプションを説明します。  

##### <cluster name>  
作成するK2HDKCクラスターのベース名を指定します。  
上記の例では、`mycluster`と指定しています。
##### --k8s_namespace <namespace>  
[kubernetes](https://kubernetes.io/)クラスターで使う`NameSpace`を指定します。  
省略された場合は、`default`を使います。
##### --k8s_domain <domain>  
[kubernetes](https://kubernetes.io/)クラスターの`ドメイン名`を指定します。  
省略された場合は、`svc.cluster.local`を使います。
##### --server_count <count>  
K2HDKCクラスターのサーバーノードを増減する数を指定します。  
省略した場合は、`2`です。
##### --slave_count <count>  
構築するK2HDKCクラスターのスレーブノードを増減する数を指定します。  
省略した場合は、`2`です。

## K2HDKCクラスター破棄
K2HDKCクラスターを破棄することができます。

以下のようにコマンドを実行します。
```
$ k2hr3 database-k8s k2hdkc delete mycluster --k8s_namespace default --k8s_domain svc.cluster.local --unscopedtoken 8855f196137d6a946eb926496cba3e02d50eb44a119dc70c06c48f55f2734e63
Removed : K2HDKC Slave Service(slvsvc-mycluster)
Removed : K2HDKC Slave StatefulSet(slvpod-mycluster)
Removed : K2HDKC Slave Pod(slvpod-mycluster-0)
Failed : Could not delete K2HDKC Slave Pod(slvpod-mycluster-1)
Failed : Could not delete K2HDKC Slave Pod(slvpod-mycluster-2)
Removed : K2HDKC Server Service(svrsvc-mycluster)
Removed : K2HDKC Server StatefulSet(svrpod-mycluster)
Removed : K2HDKC Server Pod(svrpod-mycluster-0)
Failed : Could not delete K2HDKC Server Pod(svrpod-mycluster-1)
Failed : Could not delete K2HDKC Server Pod(svrpod-mycluster-2)
Removed : K2HDKC DBaaS Secret for certificates(secret-mycluster-certs)
Removed : K2HDKC DBaaS Secret for Token(secret-mycluster-k2hr3-token)
Removed : K2HDKC DBaaS Secret for configMap(configmap-mycluster)
Removed : The certificates for the "mycluster" K2HDKC Cluster.
Removed : The configuration and related files for the "mycluster" K2HDKC Cluster.
Removed : The K2HR3 Role "mycluster/server" for "mycluster" K2HDKC cluster.
Removed : The K2HR3 Role "mycluster/slave" for "mycluster" K2HDKC cluster.
Removed : The K2HR3 Role "mycluster" for "mycluster" K2HDKC cluster.
Removed : The K2HR3 Policy "mycluster" for "mycluster" K2HDKC cluster.
Removed : The K2HR3 Resource "mycluster/server" for "mycluster" K2HDKC cluster.
Removed : The K2HR3 Resource "mycluster/slave" for "mycluster" K2HDKC cluster.
Removed : The K2HR3 Resource "mycluster" for "mycluster" K2HDKC cluster.
Removed : The K2HDKC cluster configuration firectory("/home/antpickax/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/K2HDKC-mycluster").
Succeed : Succeed deleting K2HDKC DBaaS K8S Cluster.
```

K2HDKCクラスターを破棄するには、`k2hr3 database-k8s k2hdkc delete` コマンドを実行します。  
（上記、実行例で`Failed`となっている部分は、既に対象のPodなどが存在しないときに出力されています。これらは、サービスを先に削除しているため発生していますので、気にせず進めてください。）  

このコマンドにより、K2HDKCクラスターのすべてのノードが削除されます。  
また、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムに登録していたK2HDKCクラスターの情報も破棄されます。  
もし、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムに登録しているK2HDKCクラスターの情報を残したい場合には、`--unscopedtoken`オプションを指定しないでください。  
これにより、K2HDKCクラスターの情報の削除に関するエラーが出力され、コマンドが終了し、K2HDKCクラスターの情報は保持されたままにできます。  

上記の例で指定したオプションを説明します。  

##### <cluster name>  
作成するK2HDKCクラスターのベース名を指定します。  
上記の例では、`mycluster`と指定しています。
##### --k8s_namespace <namespace>  
[kubernetes](https://kubernetes.io/)クラスターで使う`NameSpace`を指定します。  
省略された場合は、`default`を使います。
##### --k8s_domain <domain>  
[kubernetes](https://kubernetes.io/)クラスターの`ドメイン名`を指定します。  
省略された場合は、`svc.cluster.local`を使います。
##### --unscopedtoken <token>  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムにログインするための、`Unscoped Token`を指定します。  
この値は、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムにログインし、[ユーザアカウント情報のダイアログ](https://k2hr3.antpick.ax/usage_app_commonja.html)で確認できます。  

## K2HR3システムの破棄
K2HDKCクラスターを[kubernetes](https://kubernetes.io/)に構築するために使われた[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを削除する方法を説明します。  

以下のようにコマンドを実行します。
```
$ k2hr3 database-k8s k2hr3 delete --k8s_namespace default --k8s_domain svc.cluster.local --with_certs
Stopped : socat for proxy K2HR3 APP/API.
Stopped : K2HR3 APP NodePort Service(np-r3app)
Stopped : K2HR3 API NodePort Service(np-r3api)
Stopped : K2HR3 APP Deployment Service(pod-r3app)
Stopped : K2HR3 API Service(svc-r3api)
Stopped : K2HR3 API StatefusSet(pod-r3api)
Stopped : K2HDKC Service(svc-r3dkc)
Stopped : K2HDKC StatefusSet(pod-r3dkc)
Stopped : K2HR3 APP Pod(pod-r3app)
Failed : Could not stop K2HR3 APP Pod(pod-r3app)
Stopped : K2HR3 API Pod(pod-r3api)
Failed : Could not stop K2HR3 API Pod(pod-r3api)
Removed : Secret CA(secret-k2hr3-ca)
Removed : Secret Certs(secret-k2hr3-certs)
Removed : configMap(configmap-k2hr3)
Removed : ServiceAccount for K2HR3 API(sa-r3api)
Removed : Cluster Rolebinding for K2HR3 API(crb-r3api)
Removed : Cluster Role for K2HR3 API(cr-r3api)
Removed : Files related to K2HR3 systems
Succeed : Succeed deleting the K2HR3 system
```

[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを破棄するには、`k2hr3 database-k8s k2hr3 delete` コマンドを実行します。  
（上記、実行例で`Failed`となっている部分は、既に対象のPodなどが存在しないときに出力されています。これらは、サービスを先に削除しているため発生していますので、気にせず進めてください。）  

このコマンドにより、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは完全に破棄されます。  

上記の例で指定したオプションを説明します。  

##### <cluster name>  
作成するK2HDKCクラスターのベース名を指定します。  
上記の例では、`mycluster`と指定しています。
##### --k8s_namespace <namespace>  
[kubernetes](https://kubernetes.io/)クラスターで使う`NameSpace`を指定します。  
省略された場合は、`default`を使います。
##### --k8s_domain <domain>  
[kubernetes](https://kubernetes.io/)クラスターの`ドメイン名`を指定します。  
省略された場合は、`svc.cluster.local`を使います。
##### --with_certs  
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが使っていた証明書（ユーザが登録したものと自己署名証明書）も一緒に破棄する場合に指定します。  
このオプションが指定されなかった場合は、証明書は削除されません。

## その他
上記で説明した内容が、**K2HDKC DBaaS on kubernetes CLI**の基本的な使い方です。  
**K2HDKC DBaaS on kubernetes CLI** が提供するその他の K2HDKCクラスターの操作方法については、コマンドのヘルプを参照してください。  

```
$ k2hr3 database-k8s --help
```
上記で紹介した基本的なコマンド以外に、証明書の設定などのコマンドがあります。  

### K2HDKC DBaaS on kubernetes CLIのコンフィグレーション
**K2HDKC DBaaS on kubernetes CLI**のコンフィグレーションは、デフォルトとして`<User HOME directory>/.antpickax/dbaas-k8s`ディレクトリ以下に保管されます。  
このディレクトリ以下のファイルを直接編集するか、`config`サブコマンドを使って編集することで、設定を変更することができます。  
詳しくは、ヘルプもしくはソースコードを参照してください。  

### K2HDKCスレーブノードのカスタマイズ
**K2HDKC DBaaS on kubernetes CLI**により構築されるK2HDKCスレーブノードのコンテナーをカスタマイズして、自分たちのプログラム（K2HDKCスレーブノードのクライアントプログラム）を動かすための方法を説明します。

**K2HDKC DBaaS on kubernetes CLI**が起動するK2HDKCスレーブノードのコンテナーは、yamlテンプレートにより定義されています。

このyamlテンプレートは、以下のコマンドで確認できます。
```
$ k2hr3 database-k8s config list
[K2HDKC DBaaS K8S configuration]
K2HR3CLI_DBAAS_K8S_R3API_NP_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-api-nodeport.yaml.templ"
K2HR3CLI_DBAAS_K8S_R3APP_NP_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-app-nodeport.yaml.templ"
K2HR3CLI_DBAAS_K8S_R3API_PROD_JSON_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-api-production.json.templ"
K2HR3CLI_DBAAS_K8S_R3APP_PROD_JSON_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-app-production.json.templ"
K2HR3CLI_DBAAS_K8S_R3_KUSTOM_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-kustomization.yaml.templ"
K2HR3CLI_DBAAS_K8S_R3DKC_POD_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-k2hdkc.yaml.templ"
K2HR3CLI_DBAAS_K8S_R3API_POD_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-k2hr3api.yaml.templ"
K2HR3CLI_DBAAS_K8S_R3APP_POD_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-k2hr3app.yaml.templ"
K2HR3CLI_DBAAS_K8S_R3_SA_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-sa.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_K2HDKC_INI_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-k2hdkc.ini.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_INI_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc.ini.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_SVR_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-server.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-slave.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HDKC_KUSTOM_YAML_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-kustomization.yaml.templ"
K2HR3CLI_DBAAS_K8S_K2HR3_DKC_INIUPDATE_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-k2hdkc-ini-update.sh"
K2HR3CLI_DBAAS_K8S_K2HR3_API_WRAP_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-api-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_WRAP_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-app-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HR3_APP_INIT_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/k2hr3-app-init.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_CHMPXPROC_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-chmpxproc-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_SVRPROC_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-serverproc-wrap.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_INIUPDATE_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-ini-update.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_R3_REG_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-k2hr3-registration.sh"
K2HR3CLI_DBAAS_K8S_K2HDKC_VAR_SETUP_SH_TEMPL="/home/antpickax/work/k2hdkc_dbaas_k8s_cli/src/libexec/database-k8s/dbaas-k2hdkc-variables-setup.sh"
[K2HDKC DBaaS K8S cluster domains]
default.svc.cluster.local
Succeed : Completed listing the configuration of K2HDKC DBaaS K8S
```

上記は、**K2HDKC DBaaS on kubernetes CLI**のコンフィグレーションをリストした結果になります。  

この結果に表示されている **K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_TEMPL**の示す値が、K2HDKCスレーブノードのyamlテンプレートです。  
K2HDKCスレーブノードのカスタマイズする場合は、このyamlテンプレートをコピーして、修正してください。  
修正したyamlテンプレートファイルを、**K2HDKC DBaaS on kubernetes CLI**のコンフィグレーションに登録してください。  

コンフィグレーションは、`<User HOME directory>/.antpickax/dbaas-k8s/dbaas-k8s.config`ファイルに記述されています。  
この中の**K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_TEMPL**の値を、カスタマイズしたyamlテンプレートファイルのパスに変更してください。
