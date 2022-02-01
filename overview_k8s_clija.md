---
layout: contents
language: ja
title: Overview DBaaS on k8s CLI
short_desc: Database as a Service for K2HDKC
lang_opp_file: overview_k8s_cli.html
lang_opp_word: To English
prev_url: overview_clija.html
prev_string: Overview DBaaS CLI
top_url: overviewja.html
top_string: Overview
next_url: 
next_string: 
---

# K2HDKC DBaaS on kubernetes CLI 概要
**K2HDKC DBaaS on kubernetes CLI（Command Line Interface）**を使うと[kubernetes](https://kubernetes.io/) クラスター内に簡単に **K2HDKC**クラスターを**DBaaS（Database as a Service）**として構築できます。  

![K2HDKC DBaaS on kubernetes CLI Overview](images/overview_k8s_cli.png)

**K2HDKC DBaaS** でK2HDKCクラスター構築、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの構築の操作は、すべて **K2HDKC DBaaS on kubernetes CLI** から実行できます。  

**K2HDKC DBaaS** に必要となる [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムは、[kubernetes](https://kubernetes.io/) クラスター内に構築されている必要があります。  
まず最初に、[kubernetes](https://kubernetes.io/) クラスター内に[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを構築します。  
この操作は、**K2HDKC DBaaS on kubernetes CLI** を使い、簡単に実行できます。  
**K2HDKC DBaaS on kubernetes CLI** は、[kubernetes](https://kubernetes.io/) クラスター内の[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムの構築・削除ができます。  

構築した[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを使い、**K2HDKCクラスター** の構築、削除を行います。  
K2HDKCクラスターへサーバーノードの追加・削除（スケール）の操作も、**K2HDKC DBaaS on kubernetes CLI** から操作できます。  
構築した K2HDKCクラスターに接続するK2HDKCスレーブノードの起動・追加・削除も同様に操作できます。  
これらの操作によるK2HDKCクラスターノードの増減に対して、自動的なコンフィグレーションおよび自動データマージがサポートされます。  

**K2HDKC DBaaS on kubernetes CLI** による**DBaaS（Database as a Service）**の大まかなシステムの説明をします。  

## kubernetes control plane
**K2HDKC DBaaS on kubernetes CLI** は、[kubernetes](https://kubernetes.io/) クラスター Control Planeの **kube-apiserver** を使います。  
**K2HDKC DBaaS on kubernetes CLI** は、既存の[kubernetes](https://kubernetes.io/) クラスターと連携します。  

現時点で、[kubernetes](https://kubernetes.io/) クラスターの認証システムは、[OpenID Connect](https://openid.net/connect/)のみサポートしてます。  

## K2HR3 システム
[OpenStack](https://www.openstack.org/)と連動するタイプの **K2HDKC DBaaS**と同様に、[AntPickax](https://antpick.ax/indexja.html)プロダクトの一つである [K2HR3](https://k2hr3.antpick.ax/indexja.html) システムを必要とします。  
**K2HDKC DBaaS on kubernetes CLI**が、[K2HR3](https://k2hr3.antpick.ax/indexja.html) システム、[kubernetes](https://kubernetes.io/)のリソースを操作し、DBaaS機能を実現しています。  

この[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムは、**K2HDKC DBaaS**を構築する[kubernetes](https://kubernetes.io/)クラスター内に存在する必要があります。  

**K2HDKC DBaaS**が必要とする[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムを、**K2HDKC DBaaS on kubernetes CLI**を使って、構築できます。  
必要とされる[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムのコンフィグレーションは、自動的に設定されます。  

[K2HR3](https://k2hr3.antpick.ax/indexja.html) システムは、[kubernetes](https://kubernetes.io/)クラスター内に１つ存在すれば十分ですが、複数構築することもできます。  

## K2HDKC クラスター
これは、**K2HDKC DBaaS on kubernetes CLI** が構築し、起動するK2HDKCのクラスターです。  
[kubernetes](https://kubernetes.io/)クラスター内の **Compute machie(nodes)**上に、K2HDKCのクラスターの各ノードはコンテナーとして起動されます。  

**K2HDKC DBaaS on kubernetes CLI**を使って、K2HDKCのクラスターのサーバーノード、スレーブノードの作成・削除（スケール）を行うことができます。  
（直接、kubectlコマンドなどを使ってスケールすることもできます。）  

## K2HDKC スレーブノード
**K2HDKC DBaaS on kubernetes CLI**により作成されたK2HDKCクラスター（サーバーノード）に接続するノード（クライアント）のことです。  

![K2HDKC DBaaS Slave Overview](images/overview_k8s_cli_slave.png)

K2HDKCスレーブノードも、**K2HDKC DBaaS on kubernetes CLI**を使い、起動・削除できます。  
そして、**K2HDKC DBaaS on kubernetes CLI** により、自動的なコンフィグレーションがサポートされます。  

K2HDKCスレーブノードの構築に使われる[kubernetes](https://kubernetes.io/)オブジェクトは、**yamlファイル**として表現されています。  
ユーザは、**K2HDKC DBaaS on kubernetes CLI**が使う**yamlファイルのテンプレート**を変更し、自分たちに必要なコンテナーに変更して利用します。  

**K2HDKC DBaaS on kubernetes CLI** により、K2HDKCスレーブノードのプログラムから、K2HDKクラスターの構成を隠蔽し、これらのプログラムはサーバーノードの構成を意識する必要がなくなり、開発者・運用者の負荷を低減できます。  
