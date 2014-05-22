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
# setup puppet control node

# staging
stage { 'last': }
Stage['main'] -> Stage['last']
# set a default path for all execs
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/", "/opt/vagrant_ruby/bin/" ] }

# common setup
class { 'common': }

# more necessary setup..

# create volume group cinder-volumes on additional virtual hard drive
# create a Linux partition
exec { "fdisk":
  command => "/sbin/fdisk /dev/sdb << EOF
n
p
1


w
EOF",
  unless => "/bin/grep sdb1 /proc/partitions",
}
# create pv /dev/sdb1
exec { "create_pv_sdb1":
  command => "/sbin/pvcreate /dev/sdb1",
  require => Exec["fdisk"],
}
# create vg cinder-volumes
exec { "create_vg_cinder_volumes":
  command => "/sbin/vgcreate cinder-volumes /dev/sdb1",
  require => Exec["create_pv_sdb1"],
}

# setup devstack
if $env == 'devstack' {
  class {'devstack::params':
    devstack_git_url    => $devstack_git_url,
    devstack_branch     => $devstack_branch,
    openstack_branch    => $openstack_branch,
    devstack_img_name   => $devstack_img_name,
    devstack_img_urls   => $devstack_img_urls,
  }
  class {'devstack::control':
    stage           => last,
  }
}

# shell script to create tenant network for the given tenant name
# configuration in config.yaml
# $public_if = eth3
# file { "/home/vagrant/create_tenant_network.sh":
#   content   => template("/vagrant/puppet/templates/create_tenant_network.erb"),
#   mode      => "u+x",
#   group     => "vagrant",
#   owner     => "vagrant",
# }
