---
layout: contents
language: ja
title: Usage K2HDKC Helm Chart
short_desc: Database as a Service for K2HDKC
lang_opp_file: usage_helm_chart.html
lang_opp_word: To English
prev_url: usage_k8s_clija.html
prev_string: Usage DBaaS on k8s CLI
top_url: usageja.html
top_string: Usage
next_url: usage_rancher_helm_chartja.html
next_string: Usage Helm Chart with RANCHER
---

# 使い方 - K2HDKC Helm Chart
**K2HDKC Helm Chart** の使い方を説明します。  

**K2HDKC Helm Chart**は、[Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー）に対応した **Helm Chart** であり、[kubernetes](https://kubernetes.io/) に **K2HDKC DBaaS** を構築できます。  
**K2HDKC Helm Chart**で構築する **K2HDKC DBaaS** は、同じ kubernetes クラスターに構築された [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムと連携します。  

このページでは、`Helmコマンド`を使い、**K2HDKC Helm Chart**から K2HDKC DBaaSである K2HDKCクラスターを構築する方法を説明します。  

## RANCHER対応
**K2HDKC Helm Chart**は、**RANCHER Helm Chart** として利用できます。  
[RANCHER](https://www.rancher.co.jp/)のリポジトリに登録し、K2HDKCクラスターを簡単に構築できます。  
[RANCHER](https://www.rancher.co.jp/)からの利用方法は、[こちら](usage_rancher_helm_chartja.html)を参照してください。  

## kubernetes環境について
K2HDKCクラスターを構築する環境として、kubernetes環境（クラスター）を準備、もしくはそれを使える必要があります。  
利用できるkubernetes環境をお持ちでない場合、[minikube](https://minikube.sigs.k8s.io/docs/)を使い、kubernetes環境を準備できます。  

## K2HR3システムの構築
[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、K2HDKC DBaaS の K2HDKCクラスターの構築・操作をするために必要となります。  

**K2HDKC Helm Chart** が構築する K2HDKC DBaaS で利用する [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、[K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chartja.html) を使って構築できます。  
[K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chartja.html) を使った [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの構築は、[K2HR3 Helm Chartを使ったセットアップ](https://k2hr3.antpick.ax/setup_helm_chartja.html) を参照してください。  

以降の説明では、[K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chartja.html) による [K2HR3](https://k2hr3.antpick.ax/indexja.html)システム構築が完了していることを 前提として説明します。  

## Helmコマンドの準備
**K2HDKC Helm Chart** を利用するには、[Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー）が必要となります。  

**K2HDKC Helm Chart** は、**Helm3**（バージョン3）に対応してます。（Helm2には対応していませんので、注意してください。）  

まず、[Helm](https://helm.sh/ja/) のインストールをしてください。  
正確なインストール方法は、[Helmのインストール](https://helm.sh/ja/docs/intro/install/)を参照するようにしてください。  

以下のようにして、HelmをHelmコマンドを実行するホストにインストールします。  
```
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

インストール後、バージョンなどを実行し、そのインストールが正常に行われているか確認してください。  
```
$ helm version
  version.BuildInfo{Version:"v3.7.1", GitCommit:"1d11fcb5d3f3bf00dbe6fe31b8412839a96b3dc4", GitTreeState:"clean", GoVersion:"go1.16.9"}
```

## Helmリポジトリの登録
[Artifact Hub](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc) (Helm Hub)から、**K2HDKC Helm Chart**を見つけ、このChartをローカルの`repo`に登録します。  
```
$ helm search hub k2hdkc
  URL                                                 CHART VERSION  APP VERSION  DESCRIPTION
  https://artifacthub.io/packages/helm/k2hdkc/k2hdkc  1.0.0          1.0.0        K2HDKC Helm Chart - K2HDKC(K2Hash based Distrib...
```

上記の結果から、[https://artifacthub.io/packages/helm/k2hdkc/k2hdkc](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc) を確認します。  
このページの左側に **INSTALL**リンクがありますので、それをクリックしてコマンド例をコピーし、実行してください。
```
$ helm repo add k2hdkc https://helm.k2hdkc.antpick.ax/
  "k2hdkc" has been added to your repositories
```

以上で、リポジトリの登録が完了します。

## Helmインストール
登録した **K2HDKC Helm Chart** を使い、kubernetes環境に K2HDKCクラスターを構築します。  

```
$ helm install my-k2hdkc k2hdkc/k2hdkc --version 1.0.0 \
    --set k2hr3.unscopedToken=< k2hr3 unscoped token > \
    --set k2hr3.clusterName=<k2hr3 cluster name which installed by k2hr3 helm chart>
```
K2HDKC Helm Chartをインストールするときに指定できる **オプション** については、後述します。  

上記で指定しているオプションは、構築時に必要となる必須オプションです。  

上記の`helm install`が正常に完了すると、以下の`NOTES`が表示されます。  
```
  -----------------------------------------------------------------
                       CONGRATULATIONS!
  
  The my-k2hdkc K2HDKC Cluster has been started.
  
  [1] About upgrade
      If you want to change the configuration of K2HDKC Cluster,
      please do the following:
  
          $ helm upgrade my-k2hdkc k2hdkc \
            { --set <key>=<value> .... }
  
      Change the value of the variable you want to change, and specify the
      other variables that are the same as when you executed "helm install".
  
  [2] Destroy my-k2hdkc K2HDKC Cluster
      To destroy the K2HDKC Cluster, do the following:
      (See "[3] Destroy the data in my-k2hr3 K2HR3 Cluster".)
  
          $ helm uninstall my-k2hdkc
  
      After executing the above command, the following kubernetes
      resources will be remained.
  
          ConfigMap : configmap-my-k2hdkc
          Secret    : secret-my-k2hdkc-k2hr3-token
  
      To remove them completely, run the following command:
  
          $ kubectl delete configmap configmap-my-k2hdkc
          $ kubectl delete secret secret-my-k2hdkc-k2hr3-token
  
  [3] Destroy the data in my-k2hr3 K2HR3 Cluster
  
      Data dedicated to the my-k2hdkc K2HDKC Cluster is registered
      in the my-k2hr3 K2HR3 Cluster.
      Executing the "helm uninstall" command will automatically try
      to delete these data.
  
      When you executed "helm install", you should have specified
      the Unscoped Token("k2hr3.unscopedToken" variable) of the
      my-k2hr3 K2HR3 Cluster.
  
      If this Unscoped Token has not expired, the data deletion
      will be successful.
      If the Unscoped Token has expired(usually 24H), you can avoid
      the data deletion failure by updating this Unscoped Token
      before executing "helm uninstall".
  
      You can update the UnscopedToken in the following two ways:
  
      * One is to use helm upgrade:
        Execute "helm upgrade" to update "k2hr3.unscopedToken".
        (Remember to specify other variables: "[1] About upgrade")
  
        $ helm upgrade my-k2hdkc k2hdkc \
          --set k2hr3.unscopedToken=<new unscoped token> \
          { --set <key>=<value> .... }
  
      * The other is to update the kubernetes secret resource
        (secret-my-k2hdkc-K2hr3-token) directly.
        Prepare following yaml file(secret.yaml) for secret.
  
        ---------
        apiVersion: v1
        kind: Secret
        metadata:
          name: secret-my-k2hdkc-k2hr3-token
          namespace: default
          annotations:
            helm.sh/hook: pre-install,pre-upgrade
            helm.sh/hook-delete-policy: before-hook-creation
            helm.sh/hook-weight: "-1"
        type: Opaque
        data:
          unscopedToken: "<new unscoped token encoded by base64>"
        ---------
  
        Use this yaml file to update the kubernetes Secret directly.
  
        $ kubectl apply -f secret.yaml
  
      Update the kubernetes Secret(secret-my-k2hdkc-k2hr3-token)
      for the Unscoped Token using one of the above methods.
  
      After updating it, you can execute "helm uninstall" to destroy
      the data of my-k2hr3 K2HR3 Cluster.
  
      If you cannot discard the data of my-k2hr3 K2HR3 Cluster,
      please access K2HR3 Web Application and delete the ROLE /
      RESOURCE / POLICY directly.
```

## 確認（helm test）
Helmインストール後に、K2HR3システムが起動するまで少し待ってください。（数分）  
その後、インストールが正常に完了したかどうかは、以下のコマンドで確認できます。  
```
$ helm test my-k2hdkc
  NAME: my-k2hdkc
  LAST DEPLOYED: Wed Feb  9 19:00:55 2022
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE:     chkpod-my-k2hdkc
  Last Started:   Wed Feb  9 19:04:12 2022
  Last Completed: Wed Feb  9 19:06:00 2022
  Phase:          Succeeded
  NOTES:
  -----------------------------------------------------------------
  ...
  ...
```

正常にK2HDKCクラスターが起動している場合には、以下のようにPodの起動を確認できます。
```
$ kubectl get pod
  NAME                                  READY   STATUS    RESTARTS   AGE
  slvpod-my-k2hdkc-0                    3/3     Running   0          10m
  slvpod-my-k2hdkc-1                    3/3     Running   0          10m
  svrpod-my-k2hdkc-0                    3/3     Running   0          10m
  svrpod-my-k2hdkc-1                    3/3     Running   1          10m
```

## 確認
以下に示すように、構築したK2HDKCクラスターのスレーブノードのコンテナーからK2HDKCクラスターの動作確認ができます。  

```
$ kubectl exec -it slvpod-my-k2hdkc-0 --container slvk2hdkc-my-k2hdkc -- /bin/sh

/ # k2hdkclinetool -conf /etc/antpickax/slave.ini
    -------------------------------------------------------
     K2HDKC LINE TOOL
    -------------------------------------------------------
    K2HDKC library version          : 1.0.3
    K2HDKC API                      : C++
    Communication log mode          : no
    Debug mode                      : silent
    Debug log file                  : not set
    Print command lap time          : no
    Command line history count      : 1000
    Chmpx parameters:
        Configuration               : /etc/antpickax/slave.ini
        Control port                : 0
        CUK                         :
        Permanent connect           : no
        Auto rejoin                 : no
        Join giveup                 : no
        Cleanup backup files        : yes
    -------------------------------------------------------

    K2HDKC> status node
    K2HDKC server node count                       = 2
    <    chmpxid   >[<  base hash   >](      server name      ) : area element page (k2hash size/ file size )
    ----------------+-----------------+-------------------------:-----+-------+----+-------------------------
    d81f259cbfc2ddc5[0000000000000001](svrpod-my-k2hdkc-1.svrsvc-my-k2hdkc.default.svc.cluster.local) : 0% 0% 0% (298905600 / 298905600)
    d81f274fbfc2ddc5[0000000000000000](svrpod-my-k2hdkc-0.svrsvc-my-k2hdkc.default.svc.cluster.local) : 0% 0% 0% (298905600 / 298905600)

    K2HDKC> exit
    Quit.
/ # exit
```
ポッド名（`slvpod-my-k2hdkc-0`）およびコンテナー名（`slvk2hdkc-my-k2hdkc`）は、インストールオプションに対応するので、起動時のオプションを確認してください。

## 構築完了
以上の手順で、**K2HDKC Helm Chart**により、K2HDKCクラスターの構築ができます。  

構築したK2HDKCクラスターの使い方については、[K2HDKC ドキュメント](https://k2hdkc.antpick.ax/indexja.html) を参照してください。  

## K2HDKC Helm Chart オプション
K2HDKC Helm Chart を [Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー）を使い、インストール（`helm install`）するときに、オプションを指定できます。

以下に、**K2HDKC Helm Chart** が提供するオプションの一覧を以下に示します。  

| オプション名                         | 必須     | 初期値                |
|--------------------------------------|----------|-----------------------|
| `nameOverride`                       |          | `k2hr3`               |
| `fullnameOverride`                   |          | n/a                   |
| `serviceAccount.create`              |          | true                  |
| `serviceAccount.annotations`         |          | {}                    |
| `serviceAccount.name`                |          | ""                    |
| `antpickax.configDir`                |          | "/etc/antpickax"      |
| `antpickax.certPeriodYear`           |          | 5                     |
| `dbaas.clusterName`                  |          | ""                    |
| `dbaas.baseDomain`                   |          | ""                    |
| `dbaas.server.count`                 |          | 2                     |
| `dbaas.server.port`                  |          | 8020                  |
| `dbaas.server.ctlport`               |          | 8021                  |
| `dbaas.slave.count`                  |          | 2                     |
| `dbaas.slave.ctlport`                |          | 8022                  |
| `dbaas.slave.image`                  |          | ""                    |
| `dbaas.slave.command`                |          | []                    |
| `dbaas.slave.args`                   |          | []                    |
| `dbaas.slave.files`                  |          | []                    |
| `dbaas.slave.expandFiles`            |          | []                    |
| `dbaas.slave.expandFiles[].key`      |          | n/a                   |
| `dbaas.slave.expandFiles[].contents` |          | n/a                   |
| `k2hr3.clusterName`                  |          | ""                    |
| `k2hr3.baseDomain`                   |          | ""                    |
| `k2hr3.unscopedToken`                | **必須** | ""                    |
| `k2hr3.api.baseName`                 |          | ""                    |
| `k2hr3.api.intPort`                  |          | 443                   |
| `mountPoint.configMap`               |          | "/configmap"          |
| `mountPoint.ca`                      |          | "/secret-ca"          |
| `mountPoint.k2hr3Token`              |          | "/secret-k2hr3-token" |
| `k8s.namespace`                      |          | ""                    |
| `k8s.domain`                         |          | "svc.cluster.local"   |
| `unconvertedFiles.dbaas`             |          | files/*.sh            |

各々のオプションの説明をします。

### nameOverride
`fullnameOverride`オプションが指定されていない場合、完全な名前のリリース部分をオーバーライドします。  
本オプションを省略した場合、`k2hdkc`をデフォルト値として使います。  

### fullnameOverride
Chartのリリース名を（上書き）指定します。  
本オプションを省略した場合、未指定（空文字列）となります。  

### serviceAccount.create
kubernetesのサービスアカウントを作成するかどうかを指定します。  
本オプションを省略した場合、`true`をデフォルト値として使います。  

### serviceAccount.annotations
kubernetesサービスアカウントを作成する場合、そのサービスアカウントに設定する`annotations`をオブジェクトで指定します。  
本オプションを省略した場合、`{}`（空オブジェクト）をデフォルト値として使います。  

### serviceAccount.name
kubernetesサービスアカウントを作成する場合、そのサービスアカウント名を指定します。この値が空の場合、サービスアカウントは作成されません。  
本オプションを省略した場合、未指定（空文字列）となります。  

### antpickax.configDir
K2HDKCクラスターで使用するコンフィグレーションファイルのあるディレクトリパスを指定します。  
本オプションを省略した場合、`/etc/antpickax` をデフォルト値として使います。  

### antpickax.certPeriodYear
K2HDKCクラスター内部で作成し、利用するTLS自己署名証明書（CA証明書含む）の有効期間（年）を指定します。  
本オプションを省略した場合、`5（年）` をデフォルト値として使います。  

### dbaas.clusterName
K2HDKCクラスター名を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、クラスター名は Helm Chartの リリース名（`.Release.Name`）が使われます。  

### dbaas.baseDomain
K2HDKCクラスターのkubernetesクラスター内でのベースドメイン名を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、 `k8s.domain` の値が使用されます。  

### dbaas.server.count
K2HDKCクラスターのサーバーノード数を指定します。  
本オプションを省略した場合、サーバーノード数は`2`となります。

### dbaas.server.port
K2HDKCクラスターのサーバーノードのポート番号を指定します。  
本オプションを省略した場合、`8020` ポートが使用されます。  

### dbaas.server.ctlport
K2HDKCクラスターのサーバーノードの制御ポート番号を指定します。  
本オプションを省略した場合、`8021` ポートが使用されます。  

### dbaas.slave.count
K2HDKCクラスターのスレーブノード数を指定します。  
本オプションを省略した場合、スレーブノード数は`2`となります。

### dbaas.slave.ctlport
K2HDKCクラスターのスレーブノードのポート番号を指定します。  
本オプションを省略した場合、`8022` ポートが使用されます。  

### dbaas.slave.image
K2HDKCクラスターのスレーブノード用のコンテナーイメージ（docker image）を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、[antpickax/k2hdkc](https://hub.docker.com/r/antpickax/k2hdkc) :latest が使用されます。  

### dbaas.slave.command
K2HDKCクラスターのスレーブノードの起動コマンドを配列値で指定します。  
本オプションを省略した場合、未指定（`[]`）となり、`/bin/sh` が使用されます。  
このオプションを指定する場合、`dbaas.slave.*`オプションの値も確認してください。  
スレーブノードで起動したいプログラムを準備する場合には、これらのオプションを正確に設定するようにしてください。  
詳しくは、後述を参照してください。

### dbaas.slave.args
K2HDKCクラスターのスレーブノードの起動コマンド引数を配列値で指定します。  
本オプションを省略した場合、未指定（`[]`）となり、`dbaas-k2hdkc-dummyslave.sh` が使用されます。  
このオプションを指定する場合、`dbaas.slave.*`オプションの値も確認してください。  
スレーブノードで起動したいプログラムを準備する場合には、これらのオプションを正確に設定するようにしてください。  
詳しくは、後述を参照してください。

### dbaas.slave.files
K2HDKCクラスターのスレーブノードの起動コマンドで使用するためのファイルを指定します。  
この値が指定された場合には、`/configMap`に指定されたファイルが追加されます。  
指定するファイルは、K2HDKC Helm Chartのディレクトリ配下に存在する必要があります。  
本オプションを省略した場合、未指定（`[]`）となります。  
このオプションを指定する場合、`dbaas.slave.*`オプションの値も確認してください。  
詳しくは、後述を参照してください。

### dbaas.slave.expandFiles
K2HDKCクラスターのスレーブノードの起動コマンドで使用するためのファイルの内容を指定します。  
この値が指定された場合には、`/configMap`に指定されたファイルが追加されます。  
指定するファイル内容は、キーと値として定義し、配列として定義する必要があります。  
本オプションを省略した場合、未指定（`[]`）となります。  
このオプションを指定する場合、`dbaas.slave.*`オプションの値も確認してください。  
詳しくは、後述を参照してください。

### dbaas.slave.expandFiles[].key
`dbaas.slave.expandFiles`オプションの配列で指定するファイル名をこのキーで指定します。  

### dbaas.slave.expandFiles[].contents
`dbaas.slave.expandFiles`オプションの配列で指定するファイルの内容をこのキーで指定します。  

### k2hr3.clusterName
K2HDKC クラスターが必要とする K2HR3システムのクラスター名を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、 `k2hr3` の値が使用されます。  

### k2hr3.baseDomain
K2HDKC クラスターが必要とする K2HR3システムの kubernetesクラスター内でのベースドメイン名を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、 K2HDKC クラスターと同じドメイン名が使用されます。  

### k2hr3.unscopedToken
K2HDKC クラスターが必要とする K2HR3システムで発行される **K2HR3 Unscoped Token** を指定します。  
このオプションは、**必須**であり、省略できません。
この値は、K2HDKCクラスターを起動するための情報をK2HR3システムへ登録するときに使われます。  
また、この値は、K2HDKCクラスターを起動したとき、K2HDKCクラスターの各ノード（コンテナー）のK2HR3システムへの自動登録のときにも使用されます。  
**K2HR3 Unscoped Token** は、K2HR3 Web Applicationにブラウザからログインし、メニューから表示することができます。  
**K2HR3 Unscoped Token** の確認方法は、[K2HR3 Web Application 共通操作](https://k2hr3.antpick.ax/usage_app_commonja.html) の `ユーザアカウント情報` の説明を参照してください。  

### k2hr3.api.baseName
K2HDKC クラスターが必要とする K2HR3システムの REST APIサーバーのベース名を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、 `r3api` が使用されます。  

### k2hr3.api.intPort
K2HDKC クラスターが必要とする K2HR3システムの REST APIサーバーのポート番号を指定します。  
本オプションを省略した場合、`443` ポートが使用されます。  

### mountPoint.configMap
構築するK2HDKCクラスターの各コンテナーが利用する `configMap`をマウントするディレクトリパスを指定します。  
本オプションを省略した場合、`/configmap` が使用されます。  

### mountPoint.ca
構築するK2HDKCクラスターで使用する自己署名CA証明書とその秘密鍵を保管するディレクトリパスを指定します。  
本オプションを省略した場合、`/secret-ca` が使用されます。  

### mountPoint.k2hr3Token
**k2hr3.unscopedToken オプション** で指定された **K2HR3 Unscoped Token** を保管するディレクトリパスを指定します。  
本オプションを省略した場合、`/secret-k2hr3-token` が使用されます。  

### k8s.namespace
K2HDKCクラスターを構築するkubernetesクラスターで使用する `namespace`（名前空間） を指定します。  
本オプションを省略した場合、未指定（空文字列）となり、`.Release.Namespace` が使われます。  

### k8s.domain
K2HDKCクラスターを構築するkubernetesクラスターのドメイン名を指定します。  
本オプションを省略した場合、`svc.cluster.local` が使用されます。  

### unconvertedFiles.dbaas
構築するK2HDKCクラスターが使う `configMap`に登録するファイルを指定します。  
通常、この値を変更する必要はなく、省略することができます。  
省略した場合には、このHelm Chartの持つ `files` ディレクトリ以下のファイルが `configMap` として配置されます。  

## K2HDKCスレーブノードで実行するプログラム指定オプション（dbaas.slave.*）
**K2HDKC Helm Chart**で起動する K2HDKCクラスターには、K2HDKCスレーブノードが含まれています。  

K2HDKCサーバーノードは、サーバー関連プロセスである [CHMPX](https://chmpx.antpick.ax/indexja.html) 、[K2HDKC](https://k2hdkc.antpick.ax/indexja.html)　がコンテナーとして実行されます。  
K2HDKCスレーブノードは、[CHMPX](https://chmpx.antpick.ax/indexja.html) がコンテナーとして実行されます。  
そして、ユーザはK2HDKCスレーブノード上でK2HDKCスレーブとして動作するプログラムを実行することになります。  

ユーザは、K2HDKCスレーブノードで実行するプログラムを指定するために、各 **dbaas.slave オプション**を使えます。  

まず、実行するプログラムのコンテナーへの配置については、以下の3つの方法があります。  
それぞれで使用するオプションの説明をします。  

- コンテナーイメージ（docker image）に組み込む  
この方法は、予めK2HDKCスレーブノード用のコンテナーイメージにプログラムを組み込みます。  
デフォルトのコンテナーイメージを準備したイメージに変更するには、**dbaas.slave.image オプション**で指定できます。  
準備するコンテナーイメージは、[antpickax/k2hdkc](https://hub.docker.com/r/antpickax/k2hdkc) をベースイメージとして作成してください。  
- ファイルパスで指定
K2HDKCスレーブノードのコンテナーから利用できるように `configMap`にファイルとして設定しておくことができます。  
ファイルは、**dbaas.slave.files オプション**でファイルパスとして指定します。  
この指定方法では、指定するファイルは **K2HDKC Helm Chart** のChartディレクトリ以下に存在する必要があります。  
[Artifact Hub](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc) からロードして利用する場合には、利用はできません。  
代わりに、[k2hdkc_helm_chartリポジトリ](https://github.com/yahoojapan/k2hdkc_helm_chart) をクローンするなどして、手元に**K2HDKC Helm Chart** のChartディレクトリを準備してください。  
- ファイルコンテンツを指定
K2HDKCスレーブノードのコンテナーから利用できるように `configMap`にファイルとして設定しておくことができます。  
ファイルは、**dbaas.slave.expandFiles オプション** で、ファイル名、ファイルコンテンツ（内容）を指定します。  
**dbaas.slave.files オプション** と異なり、ファイルの内容を値として渡すので、ファイル実体を準備する必要はありません。  
つまり、K2HDKC Helm Chartを [Artifact Hub](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc) からロードして利用できます。  
**dbaas.slave.expandFiles オプション**には、ファイル名（`key`）とファイルコンテンツ（`contents`）を対として、配列で複数のファイルを指定できます。  

実行するファイルを上述のいずれかの方法でK2HDKCスレーブノードのコンテナーで利用できるようにしてください。  
次に、準備したプログラムをK2HDKCスレーブノードのコンテナーで実行するために、起動プログラムおよび引数を **dbaas.slave.command オプション** および **dbaas.slave.args オプション** で 指定します。  

以上のように、いくつかの **dbaas.slave オプション** を指定して、K2HDKCスレーブノードのプログラムを指定します。
