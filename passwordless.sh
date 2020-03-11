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

gluster peer probe 192.168.205.10
gluster peer probe 192.168.205.11
gluster peer probe 192.168.205.12
gluster peer probe 192.168.205.13



rm -f /home/$USER/.ssh/id_rsa
ssh-keygen -t rsa -b 2048 -N "" -f /home/$USER/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@192.168.205.10 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@192.168.205.11 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@192.168.205.12 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@192.168.205.13 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

scp -o StrictHostKeyChecking=no vagrant@192.168.205.11:/home/vagrant/kubernetes-cluster/passwordless.sh /tmp/passwordless.sh
ssh -o StrictHostKeyChecking=no vagrant@192.168.205.11 "chmod +x /tmp/passwordless.sh && /tmp/passwordless.sh"
scp -o StrictHostKeyChecking=no vagrant@192.168.205.12:/home/vagrant/kubernetes-cluster/passwordless.sh /tmp/passwordless.sh
ssh -o StrictHostKeyChecking=no vagrant@192.168.205.12 "chmod +x /tmp/passwordless.sh && /tmp/passwordless.sh"
scp -o StrictHostKeyChecking=no vagrant@192.168.205.13:/home/vagrant/kubernetes-cluster/passwordless.sh /tmp/passwordless.sh
ssh -o StrictHostKeyChecking=no vagrant@192.168.205.13 "chmod +x /tmp/passwordless.sh && /tmp/passwordless.sh"