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
# common setup for all puppet nodes

class common {

  class {'common::hosts': }

  exec { 'apt-get update':
    command => '/usr/bin/apt-get update',
  }

  package { 'git':
    ensure => present
  }

  package { 'vim':
    ensure => present
  }

  package { 'rubygems':
    ensure => present
  }

  package { 'dnsmasq':
    ensure => present,
    notify => Exec['/bin/sleep 8']
  }

  # Increase the entrprise readyness of dnsmasq by doing nothing after its installation
  exec { '/bin/sleep 8':
    refreshonly => true
  }

  # # both devstack and puppet require cloudarchive
  include apt
  apt::source { 'cloudarchive':
    location    => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
    repos       => 'main',
    release     => $puppet_cloudarchive,
    require     => Package['ubuntu-cloud-keyring'],
    include_src => false
  }

  package { 'ubuntu-cloud-keyring':
    ensure => present,
    require => Exec['apt-get update']
  }

  # for environment openstack-deploy
  # source ubuntu cloud, setup puppet
  if $env == 'puppet' {
    apt::source { 'puppetlabs':
      location    => 'http://apt.puppetlabs.com',
      repos       => 'main dependencies',
      key         => '4BD6EC30',
      key_server  => 'pgp.mit.edu'
    }

    package { 'puppet':
      ensure      => present,
      require     => Apt::Source['puppetlabs']
    }

    # permission for puppet agent to start at boot
    file { '/etc/default/puppet':
      path        => '/etc/default/puppet',
      content     => 'START=yes'
    }

    # puppet agent starts with --server=puppet by default
    service { "puppet":
      name        => "puppet",
      ensure      => running,
      enable      => true,
      hasrestart  => true,
      require     => [ Package["puppet"], File['/etc/default/puppet'] ]
    }
  }

}