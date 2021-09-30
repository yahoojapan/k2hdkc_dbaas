---
layout: contents
language: en-us
title: Usage(kubernetes CLI)
short_desc: Database as a Service for K2HDKC
lang_opp_file: usage_k8s_clija.html
lang_opp_word: To Japanese
prev_url: usage_cli.html
prev_string: Usage(kubernetes CLI)
top_url: index.html
top_string: TOP
next_url: 
next_string: 
---

# Usage
Describes how to use **K2HDKC DBaaS on kubernetes CLI** (Command Line Interface).  
**K2HDKC DBaaS on kubernetes CLI** works with [kubernetes](https://kubernetes.io/) and [K2HR3](https://k2hr3.antpick.ax/) systems.  

**K2HDKC DBaaS on kubernetes CLI** works as a plug-in for [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html).  

The [K2HR3](https://k2hr3.antpick.ax/index.html) system is required to build and operate a K2HDKC cluster with **K2HDKC DBaaS on kubernetes CLI**.  
This [K2HR3](https://k2hr3.antpick.ax/index.html) system should be built within a [kubernetes](https://kubernetes.io/) cluster.  
**K2HDKC DBaaS on kubernetes CLI** can also build and delete [K2HR3](https://k2hr3.antpick.ax/index.html) systems.  

The operations such as building the [K2HR3](https://k2hr3.antpick.ax/index.html) system and creating and deleting the K2HDKC cluster are explained below.  

In the following command example, [minikube](https://minikube.sigs.k8s.io/docs/) created a `local kubernetes cluster` and ran **K2HDKC DBaaS on kubernetes CLI** on that [kubernetes](https://kubernetes.io/) cluster.
For easy trials, you can install [minikube](https://minikube.sigs.k8s.io/docs/) and use **K2HDKC DBaaS on kubernetes CLI** with it.

## Preparing the K2HDKC DBaaS on kubernetes CLI
**K2HDKC DBaaS on kubernetes CLI** is provided as a package at [packagecloud.io](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-k8s-cli).  
The following explains how to install it as a package.  
To expand and use the source code, refer to [k2hdkc_dbaas_k8s_cli repository](https://github.com/yahoojapan/k2hdkc_dbaas_k8s_cli).  

### Before installing
First, set the repository for `packagecloud.io`.  
```
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.deb.sh | sudo bash
  or
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.rpm.sh | sudo bash
```

## Install pacakges
Then install the **K2HDKC DBaaS on kubernetes CLI** package.  
```
$ apt install k2hdkc-dbaas-k8s-cli
  or
$ yum install k2hdkc-dbaas-k8s-cli
```
_Please use each command from the package manager according to your OS environment._  

**K2HDKC DBaaS on kubernetes CLI** is a plugin for [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html), then the [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html) package will also be installed.  

### Verification
Execute the following command to check if the installation is successful.  
```
$ k2hr3 --version

K2HR3 Command Line Interface - 1.0.4(2c3f45a)

Copyright 2021 Yahoo! Japan Corporation.

K2HR3 is K2hdkc based Resource and Roles and policy Rules,
gathers common management information for the cloud.
K2HR3 can dynamically manage information as "who", "what",
"operate". These are stored as roles, resources, policies
in K2hdkc, and the client system can dynamically read and
modify these information.

This software is released under the MIT License.

-----------------------------------------------------------
K2HDKC DBaaS on kubernetes Command Line Interface - 1.0.0(3541210)

Copyright 2021 Yahoo! Japan Corporation.

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
There is no problem if the version numbers and credit of **K2HDKC DBaaS on kubernetes CLI** and [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html) are displayed.  

### K2HDKC DBaaS on kubernetes CLI commands
**K2HDKC DBaaS on kubernetes CLI** is a plugin for [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html), so use the `k2hr3` program to run **K2HDKC DBaaS on kubernetes CLI**.  
The function as **K2HDKC DBaaS on kubernetes CLI** is provided by `database-k8s` which is one subcommand of [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html).  

You can see the function of the subcommand of **K2HDKC DBaaS on kubernetes CLI** as follows.
```
$ k2hr3 database-k8s --help
```
See Help for how to use each `database-k8s` subcommand.  

## Construction of K2HR3 system
Learn how to build a [K2HR3](https://k2hr3.antpick.ax/index.html) system that will be used to build a K2HDKC cluster on [kubernetes](https://kubernetes.io/).  
Build this [K2HR3](https://k2hr3.antpick.ax/index.html) system in the same [kubernetes](https://kubernetes.io/) cluster that you build the K2HDKC DBaaS.  

Even if you build multiple K2HDKC clusters within a [kubernetes](https://kubernetes.io/) cluster, it will work on **one** [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
That is, one [K2HR3](https://k2hr3.antpick.ax/index.html) system is sufficient for one [kubernetes](https://kubernetes.io/) cluster.  
(There is no problem even if you build multiple [K2HR3](https://k2hr3.antpick.ax/index.html) systems.)  

At this time, if you build a K2HDKC cluster using **K2HDKC DBaaS on kubernetes CLI**, the [kubernetes](https://kubernetes.io/) **authentication system** only supports [OpenID Connect](https://openid.net/connect/).  

[K2HR3](https://k2hr3.antpick.ax/index.html) An example of building a system is shown below.
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
    /home/dbaas/.antpickax/dbaas-k8s/DBAAS-default.svc.cluster.local/ca.crt

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

To build the [K2HR3](https://k2hr3.antpick.ax/index.html) system, run the `k2hr3 database-k8s k2hr3 create` command.  
After this command is executed successfully, access the `Endpoint` of the `K2HR3 APP URL` displayed in the execution result with a browser.  
You can see the [K2HR3 APP(Web Appication)](https://k2hr3.antpick.ax/usage_app_common.html).  

Describes the options specified in the above example.  
Since the [K2HR3](https://k2hr3.antpick.ax/index.html) system uses the same [OpenID Connect](https://openid.net/connect/) as the [kubernetes](https://kubernetes.io/) cluster, please prepare the [OpenID Connect](https://openid.net/connect/) settings and information in advance.  

##### --k8s_namespace <namespace>  
Specifies the `NameSpace` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `default`.
##### --k8s_domain <domain>  
Specifies the `Domain name` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `svc.cluster.local`.
##### --minikube  
This option to specify if the [kubernetes](https://kubernetes.io/) cluster is created by [minikube](https://minikube.sigs.k8s.io/docs/).
##### --oidc_client_secret <string>  
Specify the `Secret` of [OpenID Connect](https://openid.net/connect/) used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system.
##### --oidc_client_id <string>  
Specify the `Client id` of [OpenID Connect](https://openid.net/connect/) used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system.
##### --oidc_issuer_url <url>  
Specify the `Issuer URL` of [OpenID Connect](https://openid.net/connect/) used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system.
##### --oidc_username_key <string>  
If the token returned by [OpenID Connect](https://openid.net/connect/) used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system has a key indicating the user name, specify that `key` name.  
This option does not need to be specified if the user name key does not exist.
##### --oidc_cookiename <string>  
Specifies the cookie name used to pass the [OpenID Connect](https://openid.net/connect/) token used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system to **K2HR3 APP**(Web Appication).
##### --oidc_cookie_expire <number>  
Specifies the expiration date of the cookie used to pass the [OpenID Connect](https://openid.net/connect/) token used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system to **K2HR3 APP**(Web Appication) in seconds.
##### --k2hr3api_nodeport_num <number>  
Specifies the port number used by the **K2HR3 API** on the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
By default, the [K2HR3](https://k2hr3.antpick.ax/index.html) system is built with `NodePort`, and the port number used by the **K2HR3 API** is set automatically.  
Specify this option if you want to specify the port number instead of setting it automatically.
##### --k2hr3app_nodeport_num <number>  
Specifies the port number used by the **K2HR3 APP**(Web Appication) on the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
By default, the [K2HR3](https://k2hr3.antpick.ax/index.html) system is built with `NodePort`, and the port number used by the **K2HR3 APP**(Web Appication) is set automatically.  
Specify this option if you want to specify the port number instead of setting it automatically.  
This option should be specified as the port number must be specified instead of automatically, because this port number is used in a part of URL redirected from [OpenID Connect](https://openid.net/connect/).
##### --nodehost_ips <ip,ip...>  
Set the IP address of each Node in the [kubernetes](https://kubernetes.io/) cluster.  
These values are used when creating the [K2HR3](https://k2hr3.antpick.ax/index.html) system self-signed certificate.  
If you do not use a self-signed certificate, or if you use [minikube](https://minikube.sigs.k8s.io/docs/), you do not need to specify it.

## K2HDKC cluster preparation
Prepare to create a K2HDKC cluster.  
Set up the information of the K2HDKC cluster to be built on the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  

Execute the setup command as follows.  
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

To set up the K2HDKC cluster information, run the `k2hr3 database-k8s k2hdkc setup` command.  
This command registers the information of the K2HDKC cluster to be built in the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
This content can be confirmed from **K2HR3 APP**(Web application).  

Describes the options specified in the above example.  

##### <cluster name>  
Specify the base name of the K2HDKC cluster to be created.  
In the above example, it is specified as `mycluster`.
##### --k8s_namespace <namespace>  
Specifies the `NameSpace` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `default`.
##### --k8s_domain <domain>  
Specifies the `Domain name` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `svc.cluster.local`.
##### --unscopedtoken <token>  
Specify the `Unscoped Token` to log in to the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
This value can be found in the [K2HR3](https://k2hr3.antpick.ax/index.html) system and in the User [Account Information Dialog](https://k2hr3.antpick.ax/usage_app_common.html).  

## Create K2HDKC cluster
Next, create a K2HDKC cluster.  

Execute the command as follows.  
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

To create a K2HDKC cluster, run the `k2hr3 database-k8s k2hdkc create` command.  
This command creates a K2HDKC cluster with the specified number of nodes.  

Describes the options specified in the above example.  

##### <cluster name>  
Specify the base name of the K2HDKC cluster to be created.  
In the above example, it is specified as `mycluster`.
##### --k8s_namespace <namespace>  
Specifies the `NameSpace` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `default`.
##### --k8s_domain <domain>  
Specifies the `Domain name` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `svc.cluster.local`.
##### --server_count <count>  
Specifies the number of server nodes in the K2HDKC cluster to build.  
If omitted, it is `2`.
##### --slave_count <count>  
Specifies the number of slave nodes in the K2HDKC cluster to build.  
If omitted, it is `2`.
##### --server_port <port number>  
Specify the internal port number of the server node of the K2HDKC cluster to be built.  
If omitted, it is `8020`.
##### --server_control_port <port number>  
Specify the internal control port number of the server node of the K2HDKC cluster to be built.  
If omitted, it is `8021`.
##### --slave_control_port <port number>  
Specify the internal control port number of the slave node of the K2HDKC cluster to be built.  
If omitted, it is `8022`.

## Scale K2HDKC cluster
You can scale in and out the nodes of a K2HDKC cluster.  

Execute the command as follows.  
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

To scale the K2HDKC cluster, run the `k2hr3 database-k8s k2hdkc scale` command.  
This command scales the K2HDKC cluster in and out with the specified number of nodes.  
You can also use [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) without using this command.(ex: `kubectl scale --replicas = <count> ...`)  

Describes the options specified in the above example.  

##### <cluster name>  
Specify the base name of the K2HDKC cluster to be created.  
In the above example, it is specified as `mycluster`.
##### --k8s_namespace <namespace>  
Specifies the `NameSpace` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `default`.
##### --k8s_domain <domain>  
Specifies the `Domain name` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `svc.cluster.local`.
##### --server_count <count>  
Specifies the number of server nodes in the K2HDKC cluster to build.  
If omitted, it is `2`.
##### --slave_count <count>  
Specifies the number of slave nodes in the K2HDKC cluster to build.  
If omitted, it is `2`.

## Delete K2HDKC cluster
You can delete the K2HDKC cluster.  

Execute the command as follows.  
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

To delete the K2HDKC cluster, run the `k2hr3 database-k8s k2hdkc delete` command.  
(The part that is `Failed` in the above execution example is output when the target pod etc. does not already exist. These occur because the command deleted the service first and can be ignored.)  

This command removes all nodes in the K2HDKC cluster.  
In addition, the information of the K2HDKC cluster registered in the [K2HR3](https://k2hr3.antpick.ax/index.html) system is also deleted.  
If you want to keep the information of the K2HDKC cluster registered in the [K2HR3](https://k2hr3.antpick.ax/index.html) system, do not specify the `--unscopedtoken` option.  
This prints an error about deleting the K2HDKC cluster information, exits the command, and allows the K2HDKC cluster information to be retained.  

Describes the options specified in the above example.  

##### <cluster name>  
Specify the base name of the K2HDKC cluster to be created.  
In the above example, it is specified as `mycluster`.
##### --k8s_namespace <namespace>  
Specifies the `NameSpace` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `default`.
##### --k8s_domain <domain>  
Specifies the `Domain name` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `svc.cluster.local`.
##### --unscopedtoken <token>  
Specify the `Unscoped Token` to log in to the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
This value can be found in the [K2HR3](https://k2hr3.antpick.ax/index.html) system and in the User [Account Information Dialog](https://k2hr3.antpick.ax/usage_app_common.html).  

## Destroy the K2HR3 system
Explains how to remove the [K2HR3](https://k2hr3.antpick.ax/index.html) system used to build a K2HDKC cluster.  

Execute the command as follows.  
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

To delete the [K2HR3](https://k2hr3.antpick.ax/index.html) system, run the `k2hr3 database-k8s k2hr3 delete` command.  
(The part that is `Failed` in the above execution example is output when the target pod etc. does not already exist. These occur because the command deleted the service first and can be ignored.)  
This command completely deletes the [K2HR3](https://k2hr3.antpick.ax/index.html) system from [kubernetes](https://kubernetes.io/) cluster.  

Describes the options specified in the above example.  

##### <cluster name>  
Specify the base name of the K2HDKC cluster to be created.  
In the above example, it is specified as `mycluster`.
##### --k8s_namespace <namespace>  
Specifies the `NameSpace` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `default`.
##### --k8s_domain <domain>  
Specifies the `Domain name` to use in the [kubernetes](https://kubernetes.io/) cluster.  
If omitted, use `svc.cluster.local`.
##### --with_certs  
Specify this to delete the certificate(both user-registered certificate and self-signed certificate) used by the [K2HR3](https://k2hr3.antpick.ax/index.html) system.  
If this option is not specified, the certificate will not be deleted.  

## Others
The contents explained above are the basic usage of **K2HDKC DBaaS on kubernetes CLI**.  
For information on how to operate other K2HDKC clusters provided by **K2HDKC DBaaS on kubernetes CLI**, refer to the command help(`--help`).  

```
$ k2hr3 database-k8s --help
```
In addition to the basic commands introduced above, there are commands such as certificate settings.  

### About Configuration
The **K2HDKC DBaaS on kubernetes CLI** configuration is stored under the `<User HOME directory>/.antpickax/dbaas-k8s` directory by default.  
You can change the settings by directly editing the files under this directory or by using the `config` subcommand.  
For details, refer to the help or source code.  

### Customize K2HDKC slave node
This explains how to customize the container of K2HDKC slave node built by **K2HDKC DBaaS on kubernetes CLI** and run their own program(that is a client program on K2HDKC slave node).  

The container for the K2HDKC slave node launched by **K2HDKC DBaaS on kubernetes CLI** is defined by the **yaml template**.  

You can check this **yaml template** file path with the following command.  
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

The above is the result of listing the configurations of **K2HDKC DBaaS on kubernetes CLI**.  

The value indicated by **K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_TEMPL** displayed in this result is the **yaml template** file path of the K2HDKC slave node.  
If you want to customize the K2HDKC slave node, copy this **yaml template** and modify it.  
Register the modified **yaml template** file in the **K2HDKC DBaaS on kubernetes CLI** configuration.  

The configuration is described in the `<User HOME directory>/.Antpickax/dbaas-k8s/dbaas-k8s.config` file.  
Change the value of **K2HR3CLI_DBAAS_K8S_K2HDKC_SLV_YAML_TEMPL** in this to the path of your customized yaml template file.  
