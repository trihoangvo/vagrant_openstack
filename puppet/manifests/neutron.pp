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
# setup puppet neutron node

# staging
stage { 'last': }
Stage['main'] -> Stage['last']
# set a default path for all execs
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/", "/opt/vagrant_ruby/bin/" ] }

# common setup
class { 'common': }

# more necessary setup..

# this script setups ip for external bridge, in order for network node to 
# start with br-ex having public ip of eth3
file { "/etc/init.d/set_ip_to_br_ex.sh":
  content   => template("/vagrant/puppet/templates/set_ip_to_br_ex.erb"),
  mode      => "+x",
  group     => "root",
  owner     => "root",
}
# also make the script start at bootup
# cannot autostart this script in /etc/network/if-up.d/ because br-ex is not up 
# at the time the external network interface eth3 is up
exec { "update-rc":
  cwd       => "/etc/init.d",
  command   => "/usr/sbin/update-rc.d set_ip_to_br_ex.sh defaults",
  require   => File['/etc/init.d/set_ip_to_br_ex.sh'],
}

# snat any public ips so that anything from inside network namespace can 
# go out of network node to the internet and find the way to go back
file { "/etc/network/if-pre-up.d/snat_floatingips":
  content   => template("/vagrant/puppet/templates/snat_floatingips.erb"),
  mode      => "+x",
  group     => "root",
  owner     => "root",
}
exec { "snat_floatingips":
  cwd       => "/etc/network/if-pre-up.d",
  command   => "/bin/sh snat_floatingips -f",
  require   => File['/etc/network/if-pre-up.d/snat_floatingips'],
}

# setup devstack
if $env == 'devstack' {
  class {'devstack::params':
    devstack_git_url => $devstack_git_url,
    devstack_branch  => $devstack_branch,
    openstack_branch => $openstack_branch,
  }
  class {'devstack::neutron':
    stage           => last,
  }
}

# this script configs l3_agent with gateway_external_network_id
#file { "/home/vagrant/set_gateway_external_network_id.sh":
#  content   => template("/vagrant/puppet/templates/set_gateway_external_network_id.erb"),
#  mode      => "+x",
#  group     => "vagrant",
#  owner     => "vagrant",
#}