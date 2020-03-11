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

sudo ssh-keygen -t rsa -b 2048 -N "" -f /data/heketi/.ssh/id_rsa
for NODE in node0 node1 node2; do scp -r /data/heketi/.ssh root@${NODE}:/data/heketi; done
for NODE in node0 node1 node2; do cat /data/heketi/.ssh/id_rsa.pub | ssh root@${NODE} "cat >> /root/.ssh/authorized_keys"; done
kubectl apply -f kubernetes/heketi-secret.yaml
kubectl apply -f kubernetes/heketi-deployment.json