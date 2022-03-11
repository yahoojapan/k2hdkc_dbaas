---
layout: contents
language: en-us
title: Usage K2HDKC Helm Chart
short_desc: Database as a Service for K2HDKC
lang_opp_file: usage_helm_chartja.html
lang_opp_word: To Japanese
prev_url: usage_k8s_cli.html
prev_string: Usage DBaaS on k8s CLI
top_url: usage.html
top_string: Usage
next_url: usage_rancher_helm_chart.html
next_string: Usage Helm Chart with RANCHER
---

# Usage - K2HDKC Helm Chart
This page explains how to use the **K2HDKC Helm Chart**.  

**K2HDKC Helm Chart** is one of **Helm Chart** for building a K2HDKC cluster as **DBaaS(Database as a Service)** using [Helm(The package manager for Kubernetes)](https://helm.sh/) in [kubernetes](https://kubernetes.io/).  
The **K2HDKC DBaaS** built with the **K2HDKC Helm Chart** works with the [K2HR3](https://k2hr3.antpick.ax/index.html) system built in the same kubernetes cluster.  

This page describes how to use the `Helm command` to build a K2HDKC cluster which is a K2HDKC DBaaS from the **K2HDKC Helm Chart**.  

### RANCHER
The **K2HDKC Helm Chart** can be used as **RANCHER Helm Chart**.  
You can easily build up a K2HDKC cluster by registering it in the [RANCHER](https://rancher.com/) repository.  
Please refer to [K2HDKC Helm Chart with RANCHER](usage_rancher_helm_chart.html) for how to use from [RANCHER](https://rancher.com/).  

## About kubernetes environment
At first, prepare or use the kubernetes cluster as the environment for installing the K2HDKC cluster.  
If you don't have a kubernetes cluster available, you can also use [minikube](https://minikube.sigs.k8s.io/docs/) to prepare your kubernetes environment.  

## Build K2HR3 system
The [K2HR3](https://k2hr3.antpick.ax/index.html) system is required to build and operate a K2HDKC cluster of K2HDKC DBaaS.  

The [K2HR3](https://k2hr3.antpick.ax/index.html) system used in K2HDKC DBaaS which is built by **K2HDKC Helm Chart** can be built using [K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chart.html).  
To build a [K2HR3](https://k2hr3.antpick.ax/index.html) system using the [K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chart.html), see [Setup - K2HR3 Helm Chart](https://k2hr3.antpick.ax/setup_helm_chart.html).  

The following explanation assumes that you have a [K2HR3](https://k2hr3.antpick.ax/index.html) system with the [K2HR3 Helm Chart](https://k2hr3.antpick.ax/helm_chart.html).  

## Preparing the Helm
To use **K2HDKC Helm Chart**, you need [Helm (The package manager for Kubernetes)](https://helm.sh/).  

**K2HDKC Helm Chart** is compatible with **Helm3**(version 3), but Helm2 is **not supported**.  

First, install [Helm](https://helm.sh/).  
See [Helm Installation](https://helm.sh/docs/intro/install/) for the exact installation method.  

Install Helm on the host as follows:  
```
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

After installation, try to run the version option etc. and check whichever the installation is succeed.  
```
$ helm version
  version.BuildInfo{Version:"v3.7.1", GitCommit:"1d11fcb5d3f3bf00dbe6fe31b8412839a96b3dc4", GitTreeState:"clean", GoVersion:"go1.16.9"}
```

## Repository registration
From [Artifact Hub(Helm Hub)](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc), find **K2HDKC Helm Chart** and register that Chart repository as the `local repository`.  
```
$ helm search hub k2hdkc
  URL                                                 CHART VERSION  APP VERSION  DESCRIPTION
  https://artifacthub.io/packages/helm/k2hdkc/k2hdkc  1.0.0          1.0.0        K2HDKC Helm Chart - K2HDKC(K2Hash based Distrib...
```

From the above results, check [https://artifacthub.io/packages/helm/k2hdkc/k2hdkc](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc) page.  
There is a **INSTALL** link on the left side of this page, click on it to copy the example command and run it.  
```
$ helm repo add k2hr3 https://helm.k2hr3.antpick.ax/
  "k2hdkc" has been added to your repositories
```

This completes the repository registration.  

## Install K2HDKC Helm Chart
Install(build) the K2HDKC cluster in the kubernetes environment using the registered **K2HDKC Helm Chart**.  

```
$ helm install my-k2hdkc k2hdkc/k2hdkc --version 1.0.0 \
    --set k2hr3.unscopedToken=< k2hr3 unscoped token > \
    --set k2hr3.clusterName=<k2hr3 cluster name which installed by k2hr3 helm chart>
```
The **options** that you can specify when installing the **K2HDKC Helm Chart** are described in later chapters.

The options specified in the above example are required at installation.  

If the above `helm install` completes successfully, you will see the following` NOTES`.  
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

## Test - helm test
After installing K2HDKC Helm Chart, please wait a moment for the K2HDKC cluster to boot.  
After that, you can check whether the installation was completed normally with the following command.  
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

If the K2HDKC cluster has booted normally, you can use the `kubectl` command to verify that the pod has booted.  
```
$ kubectl get pod
  NAME                                  READY   STATUS    RESTARTS   AGE
  slvpod-my-k2hdkc-0                    3/3     Running   0          10m
  slvpod-my-k2hdkc-1                    3/3     Running   0          10m
  svrpod-my-k2hdkc-0                    3/3     Running   0          10m
  svrpod-my-k2hdkc-1                    3/3     Running   1          10m
```

## Try to Use
As shown below, you can check the operation of the K2HDKC cluster from the container of the slave node of the constructed K2HDKC cluster.

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
The pod name(`slvpod-my-k2hdkc-0`) and container name(`slvk2hdkc-my-k2hdkc`) depends on the options at the time of installation, so check the options you started.

## Construction completed
With the above procedure, you can install a K2HDKC cluster using the **K2HDKC Helm Chart** easily.  

For how to use the built K2HDKC cluster, see [K2HDKC](https://k2hdkc.antpick.ax/index.html) documentation.  

## Options for K2HDKC Helm Chart
You can specify options when installing(`helm install`) the K2HDKC Helm Chart using [Helm (The package manager for Kubernetes)](https://helm.sh/).  

Below is a list of the options offered by the **K2HDKC Helm Chart**.  

| Options                              | Required     | Default value         |
|--------------------------------------|--------------|-----------------------|
| `nameOverride`                       |              | `k2hr3`               |
| `fullnameOverride`                   |              | n/a                   |
| `serviceAccount.create`              |              | true                  |
| `serviceAccount.annotations`         |              | {}                    |
| `serviceAccount.name`                |              | ""                    |
| `antpickax.configDir`                |              | "/etc/antpickax"      |
| `antpickax.certPeriodYear`           |              | 5                     |
| `dbaas.clusterName`                  |              | ""                    |
| `dbaas.baseDomain`                   |              | ""                    |
| `dbaas.server.count`                 |              | 2                     |
| `dbaas.server.port`                  |              | 8020                  |
| `dbaas.server.ctlport`               |              | 8021                  |
| `dbaas.slave.count`                  |              | 2                     |
| `dbaas.slave.ctlport`                |              | 8022                  |
| `dbaas.slave.image`                  |              | ""                    |
| `dbaas.slave.command`                |              | []                    |
| `dbaas.slave.args`                   |              | []                    |
| `dbaas.slave.files`                  |              | []                    |
| `dbaas.slave.expandFiles`            |              | []                    |
| `dbaas.slave.expandFiles[].key`      |              | n/a                   |
| `dbaas.slave.expandFiles[].contents` |              | n/a                   |
| `k2hr3.clusterName`                  |              | ""                    |
| `k2hr3.baseDomain`                   |              | ""                    |
| `k2hr3.unscopedToken`                | **required** | ""                    |
| `k2hr3.api.baseName`                 |              | ""                    |
| `k2hr3.api.intPort`                  |              | 443                   |
| `mountPoint.configMap`               |              | "/configmap"          |
| `mountPoint.ca`                      |              | "/secret-ca"          |
| `mountPoint.k2hr3Token`              |              | "/secret-k2hr3-token" |
| `k8s.namespace`                      |              | ""                    |
| `k8s.domain`                         |              | "svc.cluster.local"   |
| `unconvertedFiles.dbaas`             |              | files/*.sh            |

Below is a description of each option.  

### nameOverride
If the `fullnameOverride` option is not specified, it overrides the release part of the full name.  
If this option is omitted, `k2hdkc` will be used as the default value.  

### fullnameOverride
Specify(overwrite) the release name of the Chart.  
If this option is omitted, it will be used empty string.  

### serviceAccount.create
Specifies whether to create a kubernetes service account.  
If this option is omitted, `true` is used as the default value.  

### serviceAccount.annotations
When you create a kubernetes service account, specify the `annotations` to set for that service account in the object.  
If this option is omitted, `{}`(empty object) will be used as the default value.  

### serviceAccount.name
When you create a kubernetes service account, specify the service account name.  
If this value is not specified, no service account will be created.  
If this option is omitted, it will be used empty string.  

### antpickax.configDir
Specifies the directory path where the configuration files used by the K2HDKC cluster are located.  
If this option is omitted, `/etc/antpickax` will be used as the default value.  

### antpickax.certPeriodYear
Specify the validity period(year) of the TLS self-signed certificate (including CA certificate) created and used inside the K2HDKC cluster.  
If this option is omitted, `5(year)` is used as the default value.  

### dbaas.clusterName
Specifies the cluster name for the K2HDKC cluster.  
If this option is omitted, it will be used empty string and the cluster name will be set release name(`.Release.Name`) of Helm Chart.  

### dbaas.baseDomain
Specifies the base domain name of the K2HDKC cluster within the kubernetes cluster.  
If this option is omitted, it will be used empty string and the value of `k8s.domain` will be used.  

### dbaas.server.count
Specifies the number of server node of the K2HDKC cluster.  
If this option is omitted, the number of server node will be `2`.  

### dbaas.server.port
Specifies the port number of server node in K2HDKC cluster.  
If this option is omitted, it will be used `8020` port.  

### dbaas.server.ctlport
Specifies the control port number of server node in K2HDKC cluster.  
If this option is omitted, it will be used `8021` port.  

### dbaas.slave.count
Specifies the number of slave node of the K2HDKC cluster.  
If this option is omitted, the number of slave node will be `2`.  

### dbaas.slave.ctlport
Specifies the control port number of slave node in K2HDKC cluster.  
If this option is omitted, it will be used `8022` port.  

### dbaas.slave.image
Specifies a container image(docker image) for the slave nodes of the K2HDKC cluster.  
If this option is omitted, it will be used empty string and [antpickax/k2hdkc](https://hub.docker.com/r/antpickax/k2hdkc) :latest will be used.  

### dbaas.slave.command
Specify the `run program` of the slave node of the K2HDKC cluster as an array value.  
If this option is omitted, it will be set `[]` and `/bin/sh` will be used.  
If you specify this option, also check the value of the `dbaas.slave.*` options.  
Be sure to set these options correctly when preparing the program you want to launch on the slave node.  
See below section for more information.  

### dbaas.slave.args
Specify the `command arguments` of the slave node of the K2HDKC cluster as an array value.  
If this option is omitted, it will be set `[]` and `dbaas-k2hdkc-dummyslave.sh` will be used.  
If you specify this option, also check the value of the `dbaas.slave.*` options.  
Be sure to set these options correctly when preparing the program you want to launch on the slave node.  
See below section for more information.  

### dbaas.slave.files
Specifies the program file path in the K2HDKC cluster slave node.  
If this value is specified, the specified file will be added to `/configMap`.  
The specified file path must exist **under** the K2HDKC Helm Chart directory.  
If this option is omitted, it will be set `[]` and no file is added.  
If you specify this option, also check the value of the `dbaas.slave.*` options.  
Be sure to set these options correctly when preparing the program you want to launch on the slave node.  
See below section for more information.  

### dbaas.slave.expandFiles
Specifies the program file name and its contents in the K2HDKC cluster slave node.  
If this value is specified, the specified file(name / contents) will be added to `/configMap`.  
The file name and its contents you specify must be defined as a key and value, and set these pair into an array.  
If this option is omitted, it will be set `[]` and no file is added.  
If you specify this option, also check the value of the `dbaas.slave.*` options.  
Be sure to set these options correctly when preparing the program you want to launch on the slave node.  
See below section for more information.  

### dbaas.slave.expandFiles[].key
Use this key to specify the file name specified in the `dbaas.slave.expandFiles` optional array.  

### dbaas.slave.expandFiles[].contents
Use this key to specify the file contents specified in the `dbaas.slave.expandFiles` optional array.  

### k2hr3.clusterName
Specifies the cluster name of the K2HR3 system required by the K2HDKC cluster.  
If this option is omitted, it will be used empty string and the value of `k2hr3` will be used.  

### k2hr3.baseDomain
Specifies the base domain name within the kubernetes cluster of the K2HR3 system required by the K2HDKC cluster.  
If this option is omitted, it will be used empty string and the same domain name as the K2HDKC cluster will be used.  

### k2hr3.unscopedToken
Specifies the **K2HR3 Unscoped Token** issued by the K2HR3 system required by the K2HDKC cluster.  
This option is **required** and cannot be omitted.  
This value is used to register the information for booting the K2HDKC cluster with the K2HR3 system.  
This value is also used when the K2HDKC cluster is started and each node(container) of the K2HDKC cluster is automatically registered with the K2HR3 system.  

**K2HR3 Unscoped Token** can be displayed from the menu by logging in to **K2HR3 Web Application** from a browser.  
For information on how to get the **K2HR3 Unscoped Token**, refer to the description of `User Account Information` in [Usage - K2HR3 Web Application Common](https://k2hr3.antpick.ax/usage_app_common.html).

### k2hr3.api.baseName
Specifies the base name of the K2HR3 REST API required by the K2HDKC cluster.  
If this option is omitted, it will be used empty string and the value of `r3api` will be used.  

### k2hr3.api.intPort
Specifies the port number of the K2HR3 REST API required by the K2HDKC cluster.  
If this option is omitted, it will be used `443` port.  

### mountPoint.configMap
Specifies the directory path to mount the `configMap` used by each container on the K2HDKC cluster you are installing.  
If this option is omitted, `/configmap` will be used.  

### mountPoint.ca
Specifies the directory path to store the self-signed CA certificate and private key used by the K2HDKC cluster to be installed.  
If this option is omitted, `/secret-ca` will be used.  

### mountPoint.k2hr3Token
Specifies the directory path to store the **K2HR3 Unscoped Token** specified by the **k2hr3.unscopedToken** option.  
If this option is omitted, `/secret-k2hr3-token` will be used.  

### k8s.namespace
Specifies the `namespace` of the kubernetes cluster for installing the K2HDKC cluster.  
If this option is omitted, it will be used empty string and `.Release.Namespace` will be used.  

### k8s.domain
Specifies the domain name of the kubernetes cluster that installs the K2HDKC cluster.  
If this option is omitted, `svc.cluster.local` will be used.  

### unconvertedFiles.dbaas
Specify the file to be registered in the `configMap` used by the K2HDKC cluster to be built.  
Normally, you do not need to change this value and can omit it.  
If omitted, the files under the `files` directory of this Helm Chart will be placed as `configMap`.  

## Options(dbaas.slave. *) for program run on K2HDKC slave node
A K2HDKC cluster launched with **K2HDKC Helm Chart** contains a K2HDKC slave node.  

On the K2HDKC server node, the server-related processes [CHMPX](https://chmpx.antpick.ax/index.html) and [K2HDKC](https://k2hdkc.antpick.ax/index.html) are executed as containers.  

The K2HDKC slave node runs [CHMPX](https://chmpx.antpick.ax/index.html) as a container.  
And user can run a program in container that acts as a K2HDKC slave program which cooperates with [CHMPX](https://chmpx.antpick.ax/index.html).  
The user can use each **dbaas.slave** option to specify the program to run on the K2HDKC slave node.  

First, there are three ways to place the program to be executed in the container.  
The options used for each are explained below.  

- Incorporate into a container image(docker image)  
This method pre-embeds the your program in the container image for the K2HDKC slave node.  
Use the **dbaas.slave.image** option to specify the prepared your container image.  
Create the container image to be prepared using [antpickax/k2hdkc](https://hub.docker.com/r/antpickax/k2hdkc) as the base image.  
- Specified by file path
It can be set as a file in `configMap` so that it can be used from the container of the K2HDKC slave node.  
The **file path** can be specified the **dbaas.slave.files** option.  
The specified file **MUST** exist under the Chart directory of **K2HDKC Helm Chart**.  
In other words, this method cannot be used when loading and using Chart from [Artifact Hub](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc).  
Instead, you can have the **K2HDKC Helm Chart** Chart in the local directory, for example by cloning the [k2hdkc_helm_chart repository](https://github.com/yahoojapan/k2hdkc_helm_chart).  
- Specify file content
It can be set as a file in `configMap` so that it can be used from the container of the K2HDKC slave node.  
You can specify the file as a **file name** and its **contents** using the **dbaas.slave.expandFiles** option.  
Unlike the **dbaas.slave.files** option, this method can pass the contents of the file as a value, so you don't need to prepare the file entity.  
Therefore, this method can be used even if you load **K2HDKC Helm Chart** from [Artifact Hub](https://artifacthub.io/packages/helm/k2hdkc/k2hdkc).  
You can specify multiple files in an array with a pair of file name(`key`) and its contents(`contents`) to the **dbaas.slave.expandFiles** option.  

You can specify the program to run in the container of the K2HDKC slave node by any of the above methods.  
Next, you can specify the startup program and arguments with the **dbaas.slave.command** and **dbaas.slave.args** options to run your program in the container of the K2HDKC slave node.  

As mentioned above, you can run any program on the K2HDKC slave node with some **dbaas.slave** options.  
