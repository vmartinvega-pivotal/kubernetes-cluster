# Kubernetes cluster
A vagrant script for setting up a Kubernetes cluster using Kubeadm

## Software
MobaXterm **https://mobaxterm.mobatek.net/**

## Pre-requisites

 * **[Vagrant 2.1.4+](https://www.vagrantup.com)**
 * **[Virtualbox 5.2.18+](https://www.virtualbox.org)**

## How to Run

Execute the following vagrant command to start a new Kubernetes cluster, this will start one master and two nodes:

```
vagrant up
# Edit passwordless.sh depending on the number of nodes
heketi/passwordless.sh (in all nodes as vagrant and root)
# Edit setup-heketi.sh and topology.json depending on the number of nodes
heketi/setup-heketi.sh
```

You can also start invidual machines by vagrant up k8s-head, vagrant up k8s-node-1 and vagrant up k8s-node-2

If more than two nodes are required, you can edit the servers array in the Vagrantfile

```
servers = [
    {
        :name => "k8s-node-3",
        :type => "node",
        :box => "ubuntu/xenial64",
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.13",
        :mem => "2048",
        :cpu => "2"
    }
]
 ```

As you can see above, you can also configure IP address, memory and CPU in the servers array. 

## Clean-up

Execute the following command to remove the virtual machines created for the Kubernetes cluster.
```
vagrant destroy -f
```
You can destroy individual machines by vagrant destroy k8s-node-1 -f

## Examples

### Jenkins
**jenkins** folder contains yaml files to deploy jenkins on kubernetes for testing
```
jenkins
```
### Small Demo
**example** folder contains a very small example using glusterfs 
```
example/execute-demo.sh
```

### Charts
**charts** folder contains instructions to install different charts on kubernetes
```
charts/helm-charts-install.sh
```
## Licensing

[Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0).
