# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
    {
        :name => "master",
        :type => "master",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "10.0.0.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "node0",
        :type => "node",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "10.0.0.11",
        :mem => "4096",
        :cpu => "4"
    },
    {
        :name => "node1",
        :type => "node",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "10.0.0.12",
        :mem => "4096",
        :cpu => "4"
    },
	{
        :name => "node2",
        :type => "node",
        :box => "centos/7",
        :box_version => "1905.1",
        :eth1 => "10.0.0.13",
        :mem => "4096",
        :cpu => "4"
    }
]

# This script to install k8s using kubeadm will get executed after a box is provisioned
$configureBox = <<-SCRIPT
	echo ""
	echo ""
	echo "#####################"
	echo " CONFIGURE COMMON BOX"
	echo "#####################"
	echo ""
	echo ""

	echo "##################### Install basic packages ##################### "
	yum install epel-release -y
	yum install centos-release-gluster7 -y
	yum install glusterfs glusterfs-fuse gcc zlib zlib-devel openssl openssl-devel net-tools sshpass vim git screen iptables iptables-utils iptables-services wget nano -y

	echo "##################### Ip forward enabled ##################### "
	sudo bash -c " echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
    sudo sysctl -p
	
	echo "##################### Loading modules ##################### "
	modprobe dm_snapshot
	modprobe dm_mirror
	modprobe dm_thin_pool
	modprobe br_netfilter
	modprobe fuse
	echo dm_snapshot | sudo tee -a /etc/modules
	echo dm_mirror | sudo tee -a /etc/modules
	echo dm_thin_pool | sudo tee -a /etc/modules
	echo br_netfilter | sudo tee -a /etc/modules
	echo fuse | sudo tee -a /etc/modules
	
	echo "##################### Add SELinux booleans for fuse... ##################### "
	setsebool -P virt_use_fusefs 1
	setsebool -P virt_sandbox_use_fusefs 1
	
	echo "##################### Ensure firewalld.service ##################### "
	systemctl start firewalld.service
	systemctl enable firewalld.service

	firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
    firewall-cmd --zone=public --add-port=24009/tcp --permanent
    firewall-cmd --zone=public --add-service=nfs --add-service=samba --add-service=samba-client --permanent
    firewall-cmd --zone=public --add-port=111/tcp --add-port=139/tcp --add-port=445/tcp --add-port=965/tcp --add-port=2049/tcp --add-port=38465-38469/tcp --add-port=631/tcp --add-port=111/udp --add-port=963/udp --add-port=49152-49251/tcp --permanent
	firewall-cmd --permanent --zone=public --add-port=8080/tcp
	firewall-cmd --permanent --zone=public --add-port=8081/tcp
    firewall-cmd --permanent --zone=public --add-interface=eth1
	firewall-cmd --permanent --zone=public --add-interface=weave
	firewall-cmd --permanent --zone=public --add-source=172.42.42.0/24
	firewall-cmd --permanent --zone=public --add-source=10.32.0.0/12
	firewall-cmd --permanent --zone=public --add-source=192.168.0.0/16
	firewall-cmd --permanent --zone=public --add-source=122.168.0.0/16
	firewall-cmd --permanent --zone=public --add-source=10.244.0.0/16
	firewall-cmd --permanent --zone=public --add-port=10250/tcp
	firewall-cmd --permanent --zone=public --add-port=8285/udp
	firewall-cmd --permanent --zone=public --add-port=8472/udp
	firewall-cmd --permanent --zone=public --add-port=10251/tcp
	firewall-cmd --permanent --zone=public --add-port=10252/tcp
	firewall-cmd --permanent --zone=public --add-port=6443/tcp
	firewall-cmd --permanent --zone=public --add-port=9898/tcp
	firewall-cmd --zone=public --add-port=2379-2380/tcp --permanent
	firewall-cmd --zone=public --add-port=30000-32767/tcp --permanent
	firewall-cmd --reload
	
	echo "##################### Configure bridge iptables ##################### "
#cat <<EOF > /etc/sysctl.d/k8s.conf
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#EOF
#	sysctl --system
	
	sysctl net.bridge.bridge-nf-call-iptables=1
	sysctl net.bridge.bridge-nf-call-ip6tables=1
	sysctl net.bridge.bridge-nf-call-arptables=1
	
	echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee -a /etc/sysctl.conf
	echo 'net.bridge.bridge-nf-call-ip6tables=1' | sudo tee -a /etc/sysctl.conf
	echo 'net.bridge.bridge-nf-call-arptables=1' | sudo tee -a /etc/sysctl.conf
	
	sysctl --system
	
    echo "##################### Install docker ##################### "
	curl -fsSL https://get.docker.com -o get-docker.sh
    sh ./get-docker.sh
	rm get-docker.sh
	usermod -aG docker vagrant
	systemctl enable docker.service
	systemctl start docker.service

	echo "##################### kubelet requires swap off ##################### "
    swapoff -a
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
	
	echo "##################### Set SELinux in permissive mode (effectively disabling it) ##################### "
	setenforce 0
	sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
	
	echo "##################### Install kubelet kubeadm kubectl ##################### "
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

	yum -y update
	yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
	systemctl enable --now kubelet
	systemctl start kubelet.service
    
	echo "##################### Enable user/password login and reset password ##################### "
	sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
	sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
	echo "vagrant:changeme" | sudo chpasswd
	echo "root:changeme" | sudo chpasswd
	service sshd restart
	
	echo "##################### Set etc/hosts ##################### " 
	echo "10.0.0.10 master master" >> /etc/hosts
	echo "10.0.0.11 node0 node0" >> /etc/hosts
	echo "10.0.0.12 node1 node1" >> /etc/hosts
	echo "10.0.0.13 node2 node2" >> /etc/hosts

	echo "##################### Clone Vicente Repos ##################### "
	git clone https://github.com/vmartinvega-pivotal/kubernetes-cluster
	
	sudo chown -R vagrant:vagrant kubernetes-cluster
	chmod +x kubernetes-cluster/heketi/setup-heketi.sh
	chmod +x kubernetes-cluster/example/execute-demo.sh
	
SCRIPT

$configureMaster = <<-SCRIPT
	echo ""
	echo ""
	echo "#######################"
	echo "This is configureMaster"
	echo "#######################"
	echo ""
	echo ""

    # ip of this box
    IP_ADDR=`ifconfig eth1 | grep netmask | awk '{print $2}'| cut -f2 -d:`
	
    # install k8s master
    HOST_NAME=$(hostname -s)
    
	echo "##################### Install k8s master (kubeadm) ##################### "
	kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR  --node-name $HOST_NAME --pod-network-cidr=10.244.0.0/16
		
	echo "##################### copying credentials to regular user - vagrant ##################### "
	sudo -H -u vagrant bash -c 'mkdir -p $HOME/.kube'
    sudo -H -u vagrant bash -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
    sudo -H -u vagrant bash -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'
	sudo -H -u vagrant bash -c 'echo "source <(kubectl completion bash)" >> ~/.bashrc'
	
	# Fix kubelet IP
	echo "KUBELET_EXTRA_ARGS=--node-ip=${IP_ADDR}" > /etc/sysconfig/kubelet
	systemctl daemon-reload
	systemctl restart kubelet

	echo "##################### Install flannel ##################### "
	#sudo -H -u vagrant bash -c 'kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml'
	sudo -H -u vagrant bash -c 'kubectl -f /home/vagrant/kubernetes-cluster/kube-flannel.yml'
	
	# Get token to join the cluster
    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh

	echo "##################### Removing key authenticacion ##################### "
    sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    sudo service sshd restart
	
	echo "##################### Install helm 3 ##################### "
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
	rm get_helm.sh

SCRIPT

$configureNode = <<-SCRIPT
	echo ""
	echo ""
	echo "#####################"
    echo "This is configureNode"
	echo "#####################"
	echo ""
	echo ""
	
	echo "##################### Install glusterFS ##################### "
	yum install glusterfs glusterfs-fuse glusterfs-libs glusterfs-server glusterfs-common -y 
	systemctl start glusterd.service
	systemctl enable glusterd.service
		
	sshpass -f <(printf '%s\n' changeme) scp -o StrictHostKeyChecking=no vagrant@10.0.0.10:/etc/kubeadm_join_cmd.sh .

	echo "##################### Join Node to k8s cluster ##################### "
	sh ./kubeadm_join_cmd.sh
	
	# ip of this box
    IP_ADDR=`ifconfig eth1 | grep netmask | awk '{print $2}'| cut -f2 -d:`
	
	echo Environment="KUBELET_EXTRA_ARGS=--node-ip=${IP_ADDR}" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	sudo systemctl daemon-reload
	sudo systemctl restart kubelet

SCRIPT

Vagrant.configure("2") do |config|

    servers.each do |opts|
        config.vm.define opts[:name] do |config|

            config.vm.box = opts[:box]
			config.vm.box_version = opts[:box_version]
            config.vm.hostname = opts[:name]
            config.vm.network :private_network, ip: opts[:eth1]

            config.vm.provider "virtualbox" do |v|

                v.name = opts[:name]
            	v.customize ["modifyvm", :id, "--groups", "/Vicente"]
                v.customize ["modifyvm", :id, "--memory", opts[:mem]]
                v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
				
				# Añadimos discos a lso nodos (no al master)
				DISKS = 3
				NAME = opts[:name]
				v.customize [ "storagectl", :id, "--add", "scsi", "--controller", "LSILogic", "--name", "SCSI" ]
				(0..DISKS-1).each do |d|
					if opts[:type] == "node"
						unless File.exist?("disk-#{NAME}-#{d}.vdi")
							v.customize [ "createmedium", "--filename", "disk-#{NAME}-#{d}.vdi", "--size", 1024*1024 ]
						end
						v.customize [ "storageattach", :id, "--storagectl", "SCSI", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-#{NAME}-#{d}.vdi" ]
					end
				end
            end
			
            # we cannot use this because we can't install the docker version we want - https://github.com/hashicorp/vagrant/issues/4871
            #config.vm.provision "docker"

            config.vm.provision "shell", inline: $configureBox

            if opts[:type] == "master"
                config.vm.provision "shell", inline: $configureMaster
            else
                config.vm.provision "shell", inline: $configureNode
            end
        end
    end
end 