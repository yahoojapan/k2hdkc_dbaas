---
layout: contents
language: en-us
title: Usage(CLI)
short_desc: Database as a Service for K2HDKC
lang_opp_file: usage_clija.html
lang_opp_word: To Japanese
prev_url: usage.html
prev_string: Usage(Trove)
top_url: index.html
top_string: TOP
next_url: usage_k8s_cli.html
next_string: Usage(kubernetes CLI)
---

# Usage
Describes how to use **K2HDKC DBaaS CLI** (Command Line Interface).  
**K2HDKC DBaaS CLI** (Command Line Interface) works with [OpenStack](https://www.openstack.org/) components and [K2HR3](https://k2hr3.antpick.ax/) systems.  

**K2HDKC DBaaS CLI** (Command Line Interface) works as a plug-in for [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html).

This section describes how to create, scale, and delete **K2HDKC clusters** with the **K2HDKC DBaaS CLI** (Command Line Interface), and how to start automated K2HDKC slave nodes.

## 1. Install
**K2HDKC DBaaS CLI** is provided as a package at [packagecloud.io](https://packagecloud.io/app/antpickax/stable/search?q=k2hdkc-dbaas-cli).  

The following explains how to install it as a package.  
To expand and use the source code, refer to [k2hdkc_dbaas_cli repository](https://github.com/yahoojapan/k2hdkc_dbaas_cli).  

### 1.1. Before installing
First, set the repository for `packagecloud.io`.  
```
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.deb.sh | sudo bash
  or
$ curl -s https://packagecloud.io/install/repositories/antpickax/stable/script.rpm.sh | sudo bash
```

### 1.2. Install pacakges
Then install the **K2HDKC DBaaS CLI** package.  
```
$ apt install k2hdkc-dbaas-cli
  or
$ yum install k2hdkc-dbaas-cli
```
_Please use each command from the package manager according to your OS environment._  

**K2HDKC DBaaS CLI** is a plugin for [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html), then the [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html) package will also be installed.  

### 1.3. Verification
Execute the following command to check if the installation is successful.  
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
There is no problem if the version numbers of **K2HDKC DBaaS CLI** and [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html) are displayed.  

## 2. K2HDKC DBaaS CLI commands
**K2HDKC DBaaS CLI** is a plugin for [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html), so use the `k2hr3` program to run **K2HDKC DBaaS CLI**.  
The function as **K2HDKC DBaaS CLI** is provided by `database` which is one subcommand of [K2HR3 CLI](https://k2hr3.antpick.ax/cli.html).  

You can see the function of the subcommand of **K2HDKC DBaaS CLI** as follows.
```
$ k2hr3 database --help
```
See Help for how to use each `database` subcommand.  

## 3. K2HDKC DBaaS CLI preferences
**K2HDKC DBaaS CLI** works in conjunction with [K2HR3](https://k2hr3.antpick.ax/index.html) and [OpenStack](https://www.openstack.org/).  

It is assumed that each system has already been built.  
For information on building [K2HR3](https://k2hr3.antpick.ax/), see [here](https://k2hr3.antpick.ax/setup_trial.html).  
Please build the [K2HR3](https://k2hr3.antpick.ax/) system in advance so that it works with [OpenStack](https://www.openstack.org/).  

The **K2HDKC DBaaS CLI** command accesses the [K2HR3 REST API](https://k2hr3.antpick.ax/api.html) on the [K2HR3](https://k2hr3.antpick.ax/) system and the **Identity** URI on [OpenStack](https://www.openstack.org/).  
These URIs can be specified each time the command is executed, but this operation can be omitted by setting the URI as **K2HR3 CLI configuration** in advance.  
Set each URI as follows.  
```
$ k2hr3 config set K2HR3CLI_API_URI https://localhost:3000
Succeed : Set "K2HR3CLI_API_URI: https://localhost:3000"

$ k2hr3 config set K2HR3CLI_OPENSTACK_IDENTITY_URI https://localhost/identity
Succeed : Set "K2HR3CLI_OPENSTACK_IDENTITY_URI: https://localhost/identity"
```
_Replace `https://localhost:3000` and `https://localhost/identity` with the `K2HR3 REST API URI` and the `OpenStack Identity URI`, respectively._
The following explanation is based on the assumption that these URIs are set.  

## 4. Build K2HDKC Cluster
This section describes the procedure for building a **K2HDKC cluster**(server node).

First, it is assumed that the [K2HR3](https://k2hr3.antpick.ax/) system is linked with [OpenStack](https://www.openstack.org/) and has the following common user name and tenant(project).  
- Username  
`demo`
- Tenant(Project) name  
`demo`

### 4.1. Tokens
To build a **K2HDKC cluster**, you first need a Scoped token for the [K2HR3](https://k2hr3.antpick.ax/) system.  
And you will also need a Scoped token for [OpenStack](https://www.openstack.org/).  
These tokens can be specified for each command execution described below, but this operation can be omitted by setting them in advance as **K2HR3 CLI configuration**.  
Therefore, the following explanation shows an example that includes an option to store tokens in **K2HR3 CLI configuration**.  

#### 4.1.1. OpenStack Token
First, get the OpenStack Scoped token and store it in the **K2HR3 CLI configuration**.  
```
$ k2hr3 database openstack token --op_user demo --op_tenant demo --interactive --saveconfig
OpenStack User passphrase: ********
gAAAAABgYV-h9MUf_gmfKRjx5cOGilOzg7KCSjccDwoPsYYTIao8gyA_VAozAFRVnconTsYQNTxYe01OWD8bmi_zcoeFzTEmqalt0INtHgP4-XXXXdVKWPNJ7o41NMCk95Oz6f3h6IJZPjYeMItymRBclLXKF4NykELxwgBl6ZqK-Z5laTRY5Njw_v-6ulhR9EzPyGP_gDqU
```
In the above, by specifying the `--interactive(-i)` option, the passphrase is entered interactively instead of being entered on the command line.  

#### 4.1.2. K2HR3 Token
Then use the OpenStack tokens obtained above to get the K2HR3 Unscoped and Scoped tokens and store them in the **K2HR3 CLI Configuration**.  
K2HR3 Scoped tokens can also be obtained by specifying user credentials.  
For more information, see [here](https://k2hr3.antpick.ax/cli_token.html).  

```
$ k2hr3 token create token_optoken --tenant demo --saveconfig
gAAAAABgYWFJDRoCI0R96YxUkbjE0A7b6OLIoZtkdC36yMvfkSha_1-zxOAmLYYYYWGJhk1O2ZV9FElRyCLvc5_8VNTJfh1HKk2ayANoDiv6LFk6O2DE40QXDR2yed70akOAUZNcJ_Dasbkt6OeSCMX6619OZ6fbpeYsingBC3-fY2XfPwQmc2QA4pFlzwsa34Di532MxtST
```

### 4.2. Set information for K2HDKC Cluster
Before creating the server node for the **K2HDKC cluster**, set the **K2HDKC cluster** information to the [K2HR3](https://k2hr3.antpick.ax/) system.  

Execute the following command for the K2HDKC cluster to be created as `mycluster`.  
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
The `k2hdkcuser` above is the execution user of the [k2hdkc](https://k2hdkc.antpick.ax/) and [chmpx](https://chmpx.antpick.ax/) processes running on the server node of the **K2HDKC cluster**.  
By executing this command, the RESOURCE, POLICY-RULE, and ROLE of [K2HR3](https://k2hr3.antpick.ax/) are set appropriately.  
To check the information set in [K2HR3](https://k2hr3.antpick.ax/), use the operation method of [here](https://k2hr3.antpick.ax/usage_app.html).  

### 4.3. Check OpenStack information
The server node(`Virtual Machine`) of the **K2HDKC cluster** starts as an instance of the worked with [OpenStack](https://www.openstack.org/).  
The image name(or ID) and flavor name(or ID) are required to launch an instance of [OpenStack](https://www.openstack.org/).  
You can see the available image name(and ID) and flavor name(and ID) using the following command.  
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
You can specify the image name and flavor name when starting the server node(`Virtual Machine`) of the **K2HDKC cluster** explained in the next chapter.  
However, it is better to specify the image ID and flavor ID instead of them for better performance.  

### 4.4. K2HDKC Server nodes
At the end of building the **K2HDKC cluster**, start the K2HDKC server node(`Virtual Machine`).  
Start it using the following command.  
As mentioned above, start by specifying the image ID and flavor ID.  

```
$ k2hr3 database add host server mycluster myserver1 --op_keypair demo --op_flavor_id d2 --op_image_id 59aa4ab3-7e89-42fb-83f9-093d3c83737e
Succeed : Add server host(myserver1 - "99c0d9e5-a050-45f8-829c-fee6975310ad") for mycluster cluster.
```
`--op_keypair demo` is a key pair for the `demo` user that has been set to [OpenStack](https://www.openstack.org/) in advance.  

The above allows you to start the `myserver1` host as a server node for **K2HDKC cluster** `mycluster`.  
To start the server nodes for multiple **K2HDKC cluster**, repeat the above command, changing the host name.  

## 5. K2HDKC Slave nodes
Up to the above, the server node of **K2HDKC cluster** has been started.  
Here we start a slave node that connects to that server node.  
Execute the command as follows.  

```
$ k2hr3 database add host slave mycluster myslave1 --op_keypair demo --op_flavor_id d2 --op_image_id 59aa4ab3-7e89-42fb-83f9-093d3c83737e
Succeed : Add slave host(myslave1 - "0e358601-1a0f-4e43-a18a-28e7a9d14813") for mycluster cluster.
```
With the above, `myslave1` can be started as a slave node.  

## 6. Destroy nodes in K2HDKC Cluster
You can destroy the server node and slave node of the **K2HDKC cluster**.  
It can be executed with the following command.  

```
$ k2hr3 database delete host mycluster myserver4
Succeed : Delete host myserver4 from mycluster cluster(OpenStack and K2HR3).
```
This command makes no distinction between server nodes and slave nodes.  
Any node can be destroyed simply by specifying the host name.  

## 7. Destroy K2HDKC Cluster
You can destroy all server nodes, slave nodes, and all configuration information in the **K2HDKC cluster**.  
It can be executed with the following command.  

```
$ k2hr3 database delete cluster mycluster
[IMPORTANT CONFIRM] You will lose all data/server in your cluster, Do you still want to run it? (y/n) y
[NOTICE] Delete all of the cluster configuration, data, cluster hosts, and so on.
Succeed : Delete all mycluster cluster(OpenStack and K2HR3).
```
In case of **K2HDKC cluster** deletion, you will be prompted for confirmation.  
If you do not want to see this prompt, run it with the `--yes(-y)` option.  

## 8. Summary
You can easily build a **K2HDKC cluster** on [OpenStack](https://www.openstack.org/) by following steps 1 to 6 above.  
All you need is only [K2HR3](https://k2hr3.antpick.ax/) system that works with [OpenStack](https://www.openstack.org/).  
