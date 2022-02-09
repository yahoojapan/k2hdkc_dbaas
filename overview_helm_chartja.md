---
layout: contents
language: ja
title: Overview Helm Chart
short_desc: Database as a Service for K2HDKC
lang_opp_file: overview_helm_chart.html
lang_opp_word: To English
prev_url: overview_k8s_clija.html
prev_string: Overview DBaaS on k8s CLI
top_url: overviewja.html
top_string: Overview
next_url: 
next_string: 
---

# K2HDKC Helm Chart 概要
**K2HDKC Helm Chart**は、[kubernetes](https://kubernetes.io/ja/)環境に [Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー） を使って **K2HDKC**クラスター を **DBaaS（Database as a Service）** として構築するための **Helm Chart** です。  

![K2HDKC Helm Chart Overview](images/overview_helm_chart.png)

**K2HDKC Helm Chart** を使うことで、簡単にkubernetes環境へ **K2HDKC DBaaS** として、**K2HDKC クラスター**を構築できます。  
**K2HDKC Helm Chart** は、[Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー）に対応した **Helm Chart**です。  

**K2HDKC DBaaS** を利用・構築するために、[K2HR3](https://k2hr3.antpick.ax/indexja.html)システムが必要となります。  

この [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムも 同様に [Helm](https://helm.sh/ja/)を使い、簡単に構築することができます。  
[K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chartja.html) は、**K2HR3**システムを [kubernetes](https://kubernetes.io/ja/)環境に構築するための **Helm Chart** です。  

[K2HR3 Helm Chart](https://k2hr3.antpick.ax/k2hr3_helm_chartja.html) を使った**K2HR3**システムの構築方法については、[こちら](https://k2hr3.antpick.ax/setup_helm_chartja.html)を参照してください。

**K2HDKC Helm Chart** による **K2HDKC DBaaS** の大まかなシステムの説明をします。  

## Helm について
**K2HDKC Helm Chart**は、[Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー）が利用する **Helm Chart** です。  

**K2HDKC Helm Chart**は、[Artifact Hub](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc) で公開されており、どこからでも利用できます。  

Helmの使い方については、[こちら](https://helm.sh/ja/)を参照してください。

`Helmコマンド`を使い、**K2HDKC Helm Chart**から **K2HDKCクラスター** を構築する方法は、[こちら](usage_helm_chartja.html)を参照してください。  

### kubernetes control plane との関係
[Helm](https://helm.sh/ja/) コマンドは、[kubernetes](https://kubernetes.io/) Control Planeの **kube-apiserver** や、**CRD(Custom Resource Definitions)** を使って、**Helm Chart**に従って kubernetesのリソースを構築します。  
**K2HDKC Helm Chart**は、[Helm](https://helm.sh/ja/) コマンドに K2HDKC DBaaSに必要となるkubernetesリソースを指定します。  

詳しくは、[Helm](https://helm.sh/ja/) のドキュメントを参照してください。  

## K2HR3 システム
前述のとおり、**K2HDKC Helm Chart** は、他のタイプの K2HDKC DBaaSと同様に[AntPickax](https://antpick.ax/indexja.html)プロダクトの一つである [K2HR3](https://k2hr3.antpick.ax/indexja.html) システムを必要とします。  

**K2HDKC Helm Chart**を使う場合は、[K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chartja.html) を使い、事前に [K2HR3](https://k2hr3.antpick.ax/indexja.html)システムを構築してください。  

[K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chartja.html) の使い方は、[こちら](https://k2hr3.antpick.ax/setup_helm_chartja.html)を参照してください。

## K2HDKC クラスター
**K2HDKC Helm Chart** を使うことで、指定されたK2HDKCサーバーノード、スレーブノードが構築されます。  
[kubernetes](https://kubernetes.io/)クラスター内の **Compute machie(nodes)**上に、K2HDKCのクラスターの各ノードはコンテナーとして起動されます。  

[Helm](https://helm.sh/ja/) コマンドを使って、**K2HDKC Helm Chart** をインストール（`helm install`）するとき、オプションで各ノードの情報を与えることができ、用途に応じたK2HDKCクラスターを起動できます。  
例えば、起動するK2HDKCクラスターのサーバーノード台数（コンテナー数）、ポート番号などを指定できます。  

また、起動するK2HDKCクラスターのスレーブノードでは、ユーザの指定するプログラムをコンテナーとして起動できます。

**K2HDKC Helm Chart** により、複雑な K2HDKCクラスター構築のためのマニフェストファイル（yamlファイル）を準備する必要がなくなります。  
また、[Helm](https://helm.sh/ja/) コマンドに渡すオプションにより、あらかじめ準備されたカスタマイズを可能とします。  
