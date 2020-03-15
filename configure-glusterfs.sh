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

kubectl label node node0 storagenode=glusterfs
kubectl label node node1 storagenode=glusterfs
kubectl label node node2 storagenode=glusterfs

ssh -o StrictHostKeyChecking=no vagrant@node0 "sudo gluster peer probe node0"
ssh -o StrictHostKeyChecking=no vagrant@node0 "sudo gluster peer probe node1"
ssh -o StrictHostKeyChecking=no vagrant@node0 "sudo gluster peer probe node2"

