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
# setup puppet compute node

# staging
stage { 'last': }
Stage['main'] -> Stage['last']
# set a default path for all execs
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/", "/opt/vagrant_ruby/bin/" ] }

# common setup
class { 'common': }

# more necessary setup..

# setup devstack
if $env == 'devstack' {
  class {'devstack::params':
    devstack_git_url => $devstack_git_url,
    devstack_branch  => $devstack_branch,
    openstack_branch => $openstack_branch,
  }
  class {'devstack::compute':
    stage           => last,
  }
}