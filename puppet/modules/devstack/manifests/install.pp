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
# common devstack setup for all nodes:
#
# Notice: all exec commands must be run as non-root user which has 
# passwordless sudo access, e.g user "vagrant"

class devstack::install {

  # set config for pip speedup
  file { "/home/vagrant/.pip":
    ensure    => "directory",
    owner     => "vagrant",
    group     => "vagrant",
    mode      => 750,
  }

  file { "/home/vagrant/.pip/pip.conf":
    ensure    => present,
    source    => 'puppet:///modules/devstack/pip.conf',
    owner     => "vagrant",
    group     => "vagrant",
    mode      => 640,
    require   => File['/home/vagrant/.pip']
  }

  # choose localrc by regex match hostname
  $localrc_template = $hostname ? {
    /^control/ => "devstack/localrc.control.erb",
    /^compute/ => "devstack/localrc.compute.erb", # compute1, compute2
    /^neutron/ => "devstack/localrc.neutron.erb"
  }

  # provide gitlab access to user vagrant
  file { '/home/vagrant/.ssh':
    ensure    => "directory",
    group     => "vagrant",
    owner     => "vagrant",
  }
  # exec { 'create_deploykey':
  #   command => "/bin/echo -e \"Host gitlab.internal.app.telekomcloud.com\\n\\tStrictHostKeyChecking no\\n\">> /home/vagrant/.ssh/config&&/bin/echo LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcGdJQkFBS0NBUUVBdzdzRlpXOXJETmJaMHpuRklHRmE0VkUxMm1YbFQvQmlxOCt6L3RSL3UvcXZLcytyCmtYT2lNUDhOd0daTGNpUEhOa3gvSTFKSE9LdmxuQVgwd2hPUTR3bWlpSGN6OTk4ZTVwa2RwY0tCNGtOeVlKSC8KcWQ2eGY4aWI1ZVVIQkl5SUk1cnRQOVpZTC9zUjN2MHMvKytoc3R2TmtZcGlRTEtKaitWUG1HaldKdVNxSEFJYgppbzBQR1NyclZRR1RqdEVwMmlBL1JnSUZaNjdQRGZPZUdFbHhjTFBGTjg0bWd2MlNWQkllWW5xMXdsbGR4aUZhCkJ0ckJxY21NV2hHcHRMSEtLWU9EaUxxTFlxVE9MUXhncXJRTkpxZFhhdmxPcjZDSEV2cVhDYS82d1I4clRlcGgKaisvWXZ3QXJ3V0hYczBPSkoxN2h5RjZDd29PVzhCUlVyV2liQ3dJREFRQUJBb0lCQVFDQkIxSDRXMm5EamdNTQpoc0hYcGJZbVlNWFNrbWVIdWgwaHpBdUpTd1psb2sxRk9KK09oQjhBazdLNkNmVmthZ2VTV1AxYkNJdGc1Wmk0CnNRaDN4RFE0SndyWlVWT1Y3S1ZQT05MZGlncmJZTUVPdmxBKzZFbzB4Y2RYMXhJNFFuZ2dtS29iOGk0eWV4MTkKMVlLTHVhbnI0WkJ6aURsYkV4Y3lIK1hId0J5a2grS2ZwcVBhbzJXVjJOdmZHTXk0anVmUTNRYUpUQWdBL3I5RwpPWWRiRnBqUmg1NFRsS01BdjVHSll1ZzRMWG9JYSt1RFVLVWgxc2xyeXQ1K05uS1hqODIvdEFJbnQ1YkJjTUJhCjhRcE0rL0N6VHR5amR5SEJtRGdsY3JaNGd5VXUrVGYrWWRkbWVTQ29BSkM4NlR6RnZmblB0N2hLdHU4ZFpzZjYKdTBFVE1TNzVBb0dCQVBmUDdEVnArdTYrcjRyeEl3dkZWTEcycDRlUXl4bVpKSkRFUERicHIyY1VRcFdZVVlzNwp5eU5qQWVISjhPOXB4Q2FRUnJHNUpITGNzUGtCc0pLNmVFY0RxZUpEZGdqK2tMRU85d01TcG9VRXZNRFM0MEE1Ci8yclNJaDBsM2RkQVhEdDNPb2RjaDdLd2t3MmNaZjE0M0hwS1htdTY0bnBaT29zdGRqZ1BGWkJIQW9HQkFNb3kKa3h1bEUxOVVEOTJidktsSUtId1pJZW1SdEpyOUVaR1F0NVBQTWY2eTdhampNWURNOWt5dnYvRkFuNFVxZlJOVQplZXUzSEJoQ1lNT3c1cDlVVTJBVlpYcVhKMkJ3QS9aRmk0ZmcxeWU2ay9hbWtja3NqOXpic3FwNHpXcjRTMlBLCm5KaUF0VDBrTWYwVHlEeTNXdnFFVXNXOGhkbzV6NHdEMDVjNGV5VWRBb0dCQUswQjhrelFNcW9mWW5yRUlzMkMKOU1BbFh3eWNIODg5UlhQMExIM0I0LzA0L2N0bXpmZEF4Vzl0SGRFK3BRRGdmRnJYK3lMMHVPZWYvOFc0VWtmOQoreDdKQmYrN1RWcTJMdG9PTXBGb29lellBOWN5NUFqZzlOcmszWUF3QVpMWGtnektEb2lXSnY2dm05cXl4OW1RCldZemZBdEIvWnNJNExWRWhhaGwxSG43ZEFvR0JBTVg3clhXVk5wblNLdExZU213TEhyRWN2c3NBZzdKNjk3ZnIKMXdVaERSZ1N4WWpvSlRHei83dHBIMjJ2MUVMRkxzRTlwei82Qk1Wd1FXVjhFdVdSNFMyazViK2F2OUM2L2ZZbgpkSTl3eGR1OTRtSFNDYy9ORlhTeG5va3pUaGhlMVJyNmFra2RSZGwvVm44eTNvOHREaVZjYWR2NlU2b3hqeHJQCktHRGF5aUcxQW9HQkFPejRRa29KK21RbU15STBjaDdYU0VEUm0rWkVSN1FHTkpmZVVIUW1nSEw1cGUvN0Q5UTgKR0l5QXplc0tCL0NuYjBybURDdVU5NDBlTm1TN3RsZmtudVRRVU4xQTBFZm56aHQrcmhOdXpJTlpHbW1jbUpxcAppek8vZWxRV21ieW1WbWhjNkswcjhSTUpESTJ3MncyMTdIanB0MWw1M3ZybGNJMGdpcVUzSVFVVAotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=|base64 -d>/home/vagrant/.ssh/id_rsa&&chmod 600 /home/vagrant/.ssh/id_rsa",
  #   user      => "vagrant",
  #   group     => "vagrant",
  #   require => File['/home/vagrant/.ssh']
  # }

  # git checkout my devstack
  exec { "checkout_devstack":
    cwd       => $devstack::params::home_dir,
    # work around git 1.7.9.5 not supported git checkout -b <tag version>
    command   => "/usr/bin/git clone ${devstack::params::devstack_git_url} && cd devstack && git checkout ${devstack::params::devstack_branch}",
    creates   => "${devstack::params::devstack_dir}/.git",
    user      => "vagrant",
    group     => "vagrant",
    logoutput => true
    # require   => Exec['create_deploykey']
  }

  # create screenlogs dir
  file { "${devstack::params::devstack_dir}/screenlogs":
    ensure    => "directory",
    group     => "vagrant",
    owner     => "vagrant",
    require   => Exec['checkout_devstack']
  }

  # create stack log dir
  file { "${devstack::params::devstack_dir}/logs":
    ensure    => "directory",
    group     => "vagrant",
    owner     => "vagrant",
    require   => Exec['checkout_devstack'],
  }

  # create localrc
  file { "${devstack::params::devstack_dir}/localrc":
    content   => template($localrc_template),
    require   => Exec['checkout_devstack'],
    group     => "vagrant",
    owner     => "vagrant",
  }

  # run stack.sh as user vagrant
  # skip if already stack
  # Notice: stack failed when try to use user => "vagrant", that's why we must 
  #         run stack.sh with "su -c" here
  exec { "run_devstack":
    cwd       => $devstack_dir,
    command   => "/bin/su vagrant -c ${devstack::params::devstack_dir}/stack.sh &",
    unless    => "/bin/ps aux | /usr/bin/pgrep stack",
    # logoutput => true,
    timeout   => 2100, # coffee time timeout after 35 minutes
    require   => [ File["${devstack::params::devstack_dir}/localrc"], File["/home/vagrant/.pip/pip.conf"] ],
  }

}

# all configurations regarding network pluggin go here 
# e.g gre tunneling
class ovs_pluggin_config {
  ensure_config { "tenant_network_type":
    file_path    => "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini",
    section      => "OVS",
    config       => "tenant_network_type",
    config_value => "gre",
  }
  ensure_config { "tunnel_id_ranges":
    file_path    => "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini",
    section      => "OVS",
    config       => "tunnel_id_ranges",
    config_value => "1:1000",
  }
  ensure_config { "firewall_driver":
    file_path    => "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini",
    section      => "SECURITYGROUP",
    config       => "firewall_driver",
    config_value => "quantum.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver",
  }
}

# all configurations for quantum components on compute and network node
# to talk to control node
class quantum_conf {
  # ensure quantum authentication to keystone on control node
  ensure_config { "auth_host":
    file_path    => "/etc/quantum/quantum.conf",
    section      => "keystone_authtoken",
    config       => "auth_host",
    config_value => $control_ip_mngt_nw
  }

  # ensure connect to quantum db on control node
  ensure_config { "sql_connection":
    file_path    => "/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini",
    section      => "DATABASE",
    config       => "sql_connection",
    config_value => "mysql:\\/\\/root:ppp@${control_ip_mngt_nw}\\/ovs_quantum?charset=utf8"
  }
}

# all commands to update services go here
class update_services() {
  # this is dirty
  exec { "stop_all_services":
    cwd       => $devstack_dir,
    command   => "kill -9 `ps aux | grep -v grep | grep /opt/stack | awk '{print $2}'`",
    user      => "vagrant",
    group     => "vagrant",
  }
  exec { "start_all_services":
    cwd       => $devstack_dir,
    command   => "/usr/bin/screen -d -m -c ${devstack_dir}/stack-screenrc",
    user      => "vagrant",
    group     => "vagrant",
  }
}

# ensure $config in $file_path (absolute path) to have the $config_value
# define new line $config=$config_value under [$section] if $config not found
define ensure_config($file_path, $section, $config, $config_value) {
  $config_line = "${config}=${config_value}"
  exec { $config_line:
    command   => "/bin/grep -q '^${config}' ${file_path} \
                  && /bin/sed -i 's/^${config}.*/${config_line}/' ${file_path} \
                  || /bin/sed -i '/^\\[${section}\\]/a \\${config_line}' ${file_path}"
  }
}