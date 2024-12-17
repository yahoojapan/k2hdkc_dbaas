---
layout: default
language: ja
title: K2HDKC DBaaS
short_desc: Database as a Service for K2HDKC
lang_opp_file: index.html
lang_opp_word: To English
arrow_link_overview: <a href="overviewja.html" class="link-title"><span class="arrow-base link-arrow-right"></span>概要</a>
arrow_link_whatnew: <a href="whatnewja.html" class="link-title"><span class="arrow-base link-arrow-right"></span>お知らせ</a>
arrow_link_sourcecode: <a class="link-title"><span class="arrow-base link-arrow-right"></span>ソースコード</a>
arrow_link_usage: <a href="usageja.html" class="link-title"><span class="arrow-base link-arrow-right"></span>使い方</a>
---

# **K2HDKC DBaaS**
**K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[K2HR3](https://k2hr3.antpick.ax/indexja.html)を使い、[OpenStack](https://www.openstack.org/) および [kubernetes](https://kubernetes.io/) と連動して、分散KVSである [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) の環境を構築する**Database as a Service**です。  

[OpenStack](https://www.openstack.org/) と連動する **K2HDKC DBaaS** (Database as a Service for K2HDKC) は、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove)のDatabaseの一つとして[K2HDKC](https://k2hdkc.antpick.ax/indexja.html) を利用できるようにしたタイプと、[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove)を使わず、コマンドラインから[K2HDKC](https://k2hdkc.antpick.ax/indexja.html)クラスターを構築できる**K2HDKC DBaaS CLI（Command Line Interface）**があります。  

また、[kubernetes](https://kubernetes.io/) と連動する **K2HDKC DBaaS** (Database as a Service for K2HDKC) として、コマンドラインから [K2HDKC](https://k2hdkc.antpick.ax/indexja.html) クラスターを構築できる **K2HDKC DBaaS on kubernetes CLI（Command Line Interface）** が提供されています。  

**K2HDKC DBaaS** は、Yahoo! JAPANがオープンソースとして公開するプロダクト [AntPickax](https://antpick.ax/indexja.html) のひとつです。  

![K2HDKC DBaaS](images/top_k2hdkc_dbaas.png)

## {{ page.arrow_link_overview }}
**K2HDKC DBaaS** の[概要](overviewja.html)について説明します。  

以下は、それぞれのタイプの**K2HDKC DBaaS**の概要説明です。  

- [K2HDKC DBaaS with Trove](overview_troveja.html)  
[Trove(Trove is Database as a Service for OpenStack)](https://wiki.openstack.org/wiki/Trove)と連携する**K2HDKC DBaaS** (Database as a Service for K2HDKC)の概要です。
- [K2HDKC DBaaS CLI](overview_clija.html)  
[OpenStack](https://www.openstack.org/) と連携する**K2HDKC DBaaS** (Database as a Service for K2HDKC)の概要です。
- [K2HDKC DBaaS on kubernetes CLI](overview_k8s_clija.html)  
[kubernetes](https://kubernetes.io/ja/) と連携する**K2HDKC DBaaS** (Database as a Service for K2HDKC)の概要です。
- [K2HDKC Helm Chart](overview_helm_chartja.html)  
[Helm](https://helm.sh/ja/)（Kubernetes用パッケージマネージャー） を使い、[kubernetes](https://kubernetes.io/ja/)と連動する **K2HDKC DBaaS** (Database as a Service for K2HDKC)の概要です。  
**K2HDKC Helm Chart** の [RANCHER](https://www.rancher.co.jp/) 対応についても説明します。  

## {{ page.arrow_link_whatnew }}
**K2HDKC DBaaS** について、新着情報などの[お知らせ](whatnewja.html)です。

## {{ page.arrow_link_sourcecode }}

それぞれのタイプのK2HDKC DBaaSのソースコートは、以下に示すGithubリポジトリにあります。  

- [k2hdkc_dbaas_troveリポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_trove)   
**K2HDKC DBaaS with Trove** のソースコード
- [k2hdkc_dbaas_cliリポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_cli)  
**K2HDKC DBaaS CLI**（Command Line Interface）のソースコード
- [k2hdkc_dbaas_k8s_cliリポジトリ](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli)  
**K2HDKC DBaaS on kubernetes CLI**（Command Line Interface）のソースコード
- [k2hdkc_helm_chartリポジトリ](https://github.com/yahoojapan/k2hdkc_helm_chart)  
**K2HDKC Helm Chart** のソースコード

## {{ page.arrow_link_usage }}

すべての **K2HDKC DBaaS** について、[使い方](usageja.html)で その使用方法を説明します。  

それぞれの **K2HDKC DBaaS** の使い方は、以下のリンクから直接参照することができます。  

- **K2HDKC DBaaS** with [Trove](https://wiki.openstack.org/wiki/Trove) の使い方は、[こちら](usage_troveja.html)を参照してください。
- **K2HDKC DBaaS CLI**（Command Line Interface）の使い方は、[こちら](usage_clija.html)を参照してください。
- **K2HDKC DBaaS on kubernetes CLI**（Command Line Interface）の使い方は、[こちら](usage_k8s_clija.html)を参照してください。
- **K2HDKC Helm Chart** の使い方は、[こちら](usage_helm_chartja.html)を参照してください。
- **K2HDKC Helm Chart** の使い方は、[こちら](usage_helm_chartja.html)を参照してください。
- **K2HDKC Helm Chart** を [RANCHER](https://www.rancher.co.jp/)から使う説明は、[こちら](usage_rancher_helm_chartja.html)を参照してください。

# **AntPickaxについて**
[AntPickax](https://antpick.ax/indexja.html)は、Yahoo! JAPANがオープンソースとして公開する一連のプロダクト群です。  
詳細は、[AntPickax](https://antpick.ax/indexja.html) を参照してください。
