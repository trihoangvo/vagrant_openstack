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
#
# global config for devstack environment

class devstack::params (
  # control node mgnt ip
  $control_ip_mngt_nw  = '192.168.56.2',
  # where devstack will be clone
  $home_dir            = "/home/vagrant",
  # devstack respository
  $devstack_git_url    = "https://github.com/openstack-dev/devstack.git",
  # runtime data
  # do not store openstack runtime data inside "/opt/stack" if we want 
  # to set "/opt/stack" in syn with our working directory on host machine
  $openstack_data_dir  = "/opt/data",
  # branch
  $devstack_branch     = "master",
  $openstack_branch    = "master",
  $devstack_img_name   = undef,
  $devstack_img_urls   = undef,
) {
  $devstack_dir        = "${home_dir}/devstack"
}