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

class devstack::control inherits devstack::params {

  # node settings
  $local_ip_mngt_nw = $ipaddress_eth1 # management network
  $local_ip_data_nw = $ipaddress_eth2 # data network
  $local_ip_ext_nw = $ipaddress_eth3 # public external network

  # get devstack and deploy if necessary
  include devstack::install

}

# define network node
class devstack::neutron inherits devstack::params {

  # node settings
  $local_ip_mngt_nw = $ipaddress_eth1 # management network
  $local_ip_data_nw = $ipaddress_eth2 # data network
  $local_ip_ext_nw = $ipaddress_eth3 # public external network

  # add missing package when running stack.sh
  package {'python-dev':
    ensure      => present,
  }

  # get devstack and deploy if necessary
  include devstack::install

  # add missing tasks done by stack.sh

  # persist net.ipv4.ip_forward=1
  # ip_forward is enabled by stack.sh but not yet persisted
  exec { "ipv4.ip_forward":
    command   => "sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' \
                  /etc/sysctl.conf",
  }

  # add eth3 to br-ex when stack.sh completed
  file { "/tmp/add_port_br_ex.sh":
    source    => 'puppet:///modules/devstack/add_port_br_ex.sh',
    group     => "vagrant",
    owner     => "vagrant",
    mode      => "u+x",
  }
  exec { "add_port_br_ex":
    command   => "/tmp/add_port_br_ex.sh &",
    require   => [ File["/tmp/add_port_br_ex.sh"], Class["devstack::install"] ],
  }

}

class devstack::compute inherits devstack::params {
  # node settings
  $local_ip_mngt_nw = $ipaddress_eth1 # management network
  $local_ip_data_nw = $ipaddress_eth2 # data network
  $local_ip_ext_nw = $ipaddress_eth3 # public external network

  # add missing package when running stack.sh
  package {'python-dev':
    ensure      => present,
  }

  # get devstack and deploy if necessary
  include devstack::install
}