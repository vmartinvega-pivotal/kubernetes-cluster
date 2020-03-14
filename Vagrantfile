# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
    {
        :name => "master",
        :type => "master",
        :box => "ubuntu/xenial64",
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "node0",
        :type => "node",
        :box => "ubuntu/xenial64",
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.11",
        :mem => "4096",
        :cpu => "4"
    },
    {
        :name => "node1",
        :type => "node",
        :box => "ubuntu/xenial64",
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.12",
        :mem => "4096",
        :cpu => "4"
    },
	{
        :name => "node2",
        :type => "node",
        :box => "ubuntu/xenial64",
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.13",
        :mem => "4096",
        :cpu => "4"
    }
]

# This script to install k8s using kubeadm will get executed after a box is provisioned
$configureBox = <<-SCRIPT
	echo ""
	echo ""
	echo "####################"
	echo "This is configureBox"
	echo "####################"
	echo ""
	echo ""
	
	apt-get install -y git 
	
    # install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh ./get-docker.sh
	rm get-docker.sh
	
    # run docker commands as vagrant user (sudo not required)
    usermod -aG docker vagrantconfigureBox
	
	sysctl net.bridge.bridge-nf-call-iptables=1
	
	# ensure legacy binaries are installed
	sudo apt-get install -y iptables arptables ebtables

	# switch to legacy versions
	sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
	sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
	sudo update-alternatives --set arptables /usr/sbin/arptables-legacy
	sudo update-alternatives --set ebtables /usr/sbin/ebtables-legacy

    # install kubeadm
    apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    # kubelet requires swap off
    swapoff -a

    # keep swap off after reboot
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    sudo systemctl restart kubelet
		
	# Enable user/password login and reset password
	sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
	sed -i "s/.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
	echo "vagrant:changeme" | sudo chpasswd
	echo "root:changeme" | sudo chpasswd
	service sshd restart
	
	echo "192.168.205.10 master master" >> /etc/hosts
	echo "192.168.205.11 node0 node0" >> /etc/hosts
	echo "192.168.205.12 node1 node1" >> /etc/hosts
	echo "192.168.205.13 node2 node2" >> /etc/hosts
	
	mkdir -p /data/heketi/{db,.ssh} && chmod 700 /data/heketi/.ssh
	
	apt-get install python-minimal -y
	
	git clone https://github.com/vmartinvega-pivotal/kubernetes-cluster
	git clone https://github.com/vmartinvega-pivotal/gluster-kubernetes
	
	sudo chown -R vagrant:vagrant kubernetes-cluster
	sudo chown -R vagrant:vagrant gluster-kubernetes
	
SCRIPT

$configureMaster = <<-SCRIPT
	echo ""
	echo ""
	echo "#######################"
	echo "This is configureMaster"
	echo "#######################"
	echo ""
	echo ""

    # Ip forward enabled
	sudo bash -c " echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
    sudo sysctl -p

    # ip of this box
    IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`
	
    # install k8s master
    HOST_NAME=$(hostname -s)
    
	kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR  --node-name $HOST_NAME --pod-network-cidr=10.244.0.0/16
    	
    #copying credentials to regular user - vagrant
	sudo -H -u vagrant bash -c 'mkdir -p $HOME/.kube'
    sudo -H -u vagrant bash -c 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
    sudo -H -u vagrant bash -c 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'
	sudo -H -u vagrant bash -c 'echo "source <(kubectl completion bash)" >> ~/.bashrc'
	
	sudo -H -u vagrant bash -c 'kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml'
	
	# Get token to join the cluster
    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh

    # required for setting up password less ssh between guest VMs
    sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    sudo service sshd restart
	
	# Install helm 3
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
	
	apt-get install -y sshpass
	
	# Install glusterFS
	apt-get install xfsprogs attr -y
	apt-get install glusterfs-server glusterfs-client glusterfs-common -y
	systemctl enable glusterfs-server
	
	mkfs.xfs /dev/sdc
	mkfs.xfs /dev/sdd
	mkfs.xfs /dev/sde
	
	mkdir -p /gluster/{c,d,e}
	
	su -c 'echo "/dev/sdc /gluster/c xfs defaults 0 0" >> /etc/fstab'
	su -c 'echo "/dev/sdd /gluster/d xfs defaults 0 0" >> /etc/fstab'
	su -c 'echo "/dev/sde /gluster/e xfs defaults 0 0" >> /etc/fstab'
	
	mount -a
	
	mkdir /gluster/{c,d,e}/brick
	
	modprobe dm_snapshot
	modprobe dm_mirror
	modprobe dm_thin_pool
	
	echo dm_snapshot | sudo tee -a /etc/modules
	echo dm_mirror | sudo tee -a /etc/modules
	echo dm_thin_pool | sudo tee -a /etc/modules
	
	sshpass -f <(printf '%s\n' changeme) scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .

    sh ./kubeadm_join_cmd.sh

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