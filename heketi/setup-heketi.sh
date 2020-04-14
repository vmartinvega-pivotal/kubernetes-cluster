#!/bin/bash
# Copyright (c) 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

curl -s https://api.github.com/repos/heketi/heketi/releases/latest \
  | grep browser_download_url \
  | grep linux.amd64 \
  | cut -d '"' -f 4 \
  | wget -qi -
  
for i in `ls | grep heketi | grep .tar.gz`; do tar xvf $i; done

sudo cp heketi/{heketi,heketi-cli} /usr/local/bin

sudo groupadd --system heketi
sudo useradd -s /sbin/nologin --system -g heketi heketi

sudo mkdir -p /var/lib/heketi /etc/heketi /var/log/heketi

sudo cp heketi.json /etc/heketi/heketi.json
sudo cp heketi.env /etc/heketi/heketi.env
sudo cp topology.json /etc/heketi/topology.json 
sudo cp heketi.service /etc/systemd/system/heketi.service

sudo ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
sudo ssh-copy-id -i /etc/heketi/heketi_key root@node0
sudo ssh-copy-id -i /etc/heketi/heketi_key root@node1
sudo ssh-copy-id -i /etc/heketi/heketi_key root@node2

sudo chown -R heketi:heketi /var/lib/heketi /var/log/heketi /etc/heketi

sudo systemctl daemon-reload
sudo systemctl enable --now heketi

sudo ssh -o StrictHostKeyChecking=no vagrant@node0 "sudo gluster peer probe node0"
sudo ssh -o StrictHostKeyChecking=no vagrant@node0 "sudo gluster peer probe node1"
sudo ssh -o StrictHostKeyChecking=no vagrant@node0 "sudo gluster peer probe node2"

heketi-cli topology load --user admin --secret changeme --json=/etc/heketi/topology.json

kubectl create -f heketi-secret.yaml
kubectl create -f heketi-storage-class.yaml
