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
## Contributors:
# Willy Otto <w.otto@telekom.de>
##
# Populate /etc/hosts

class common::hosts {

  host { 'puppet.local':
    ip => '192.168.56.10',
    host_aliases => 'puppet'
  }

  host { 'control.local':
    ip => '192.168.56.2',
    host_aliases => 'control'
  }

  host { 'compute1.local':
    ip => '192.168.56.31',
    host_aliases => 'compute1'
  }

  host { 'compute2.local':
    ip => '192.168.56.32',
    host_aliases => 'compute2'
  } 

  host { 'neutron1.local':
    ip => '192.168.56.41',
    host_aliases => 'neutron1'
  }

  host { 'neutron2.local':
    ip => '192.168.56.42',
    host_aliases => 'neutron2'
  }

}