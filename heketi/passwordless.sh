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

rm -f ~/.ssh/id_rsa
mkdir -p ~/.ssh/
rm -f ~/.ssh/known_hosts
ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@10.0.0.10 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@10.0.0.11 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@10.0.0.12 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | sshpass -f <(printf '%s\n' changeme) ssh -o StrictHostKeyChecking=no vagrant@10.0.0.13 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
© 2020 GitHub, Inc.