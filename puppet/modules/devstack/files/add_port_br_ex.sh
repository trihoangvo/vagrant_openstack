#!/usr/bin/env bash
#
# Copyright (C) 2014 Deutsche Telekom
# Author: Tri Hoang Vo <vohoangtri at gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

while true; do
    pgrep -f stack.sh >& /dev/null
    if [[ $? -eq 1 ]]; then
        sudo ovs-vsctl add-port br-ex eth3
        sudo /etc/init.d/set_ip_to_br_ex.sh
        exit 0
    fi
    echo "sleep"
    sleep 20
done