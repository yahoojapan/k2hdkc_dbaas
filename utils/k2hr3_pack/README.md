# K2HR3 PACK for K2HDKC DBaaS

## Overview
This directory is a developer development tool for booting K2HR3 systems on a single Virtaul Machine.  
By running the scripts in this directory, you can boot the entire K2HR3 system with one Virtaul Machine.  
The booted K2HR3 system can act as a backend for K2HD KC DBaaS.  

## Start-up
### About the environment
This tool launches a minimal process on your K2HR3 system in one OpenStack Virtual Machine.  

To use it, execute the script provided under this directory in the Virtual Machine started by OpenStack.  
The K2HR3 system boots on the OpenStack private network, so to access it from the outside, use haproxy etc. on the parent HOST to proxy the request.  
_Outputs a sample configuration for launching HAProxy._  

#### Execution environment
- (1) Start the Virtual Machine with OpenStack.
- (2) Copy this directory to this Virtual Machine and execute the script.

### Run processes
The following example uses Openstack of K2HDKC DBaaS and starts ubuntu as one Virtual Machine.  
This is the command line when running this K2HR3 pack script on ubuntu (Virtual Machine).  
And it is assumed that HAProxy will also start.  
```
[Example 1: Not using HAproxy]
  $ bin/onepack.sh -ni -nc --run_user nobody --openstack_region RegionOne --keystone_url http://<openstack identity host>/identity --app_port 80 --app_host <virtual machine ip address> --api_port 18080 --api_host <virtual machine ip address>

[Example 2: Using HAproxy]
  $ bin/onepack.sh -ni -nc --run_user nobody --openstack_region RegionOne --keystone_url http://<openstack identity host>/identity --app_port 80 --app_port_external 28080 --app_host <virtual machine ip address> --app_host_external <parent host ip address> --api_port 18080 --api_port_external 18080 --api_host <virtual machine ip address> --api_host_external <parent host ip address>
```
_http://\<openstack identity host\>/identity is the Openstack Keystone URL and RegionOne is the region name._

When starting HAProxy, the `conf/haproxy_example.cfg` file will be created after executing the above command.  
Use this to start HAProxy (`haproxy -f haproxy_example.cfg`) on the parent HOST.  

### Stop processes
We provide a tool to stop K2HR3 started by this tool.  
Please execute as follows.  
```
$ bin/stoppack.sh
```
If you want to delete unnecessary files, specify the options as follows.  
```
$ bin/stoppack.sh --clear
```
