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

# set a default path for all execs
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin/", "/opt/vagrant_ruby/bin/" ] }

# common setup
class { 'common': }

#   # fixes issue with domain names set by provider virtualbox which makes puppetdb installation fail on macos
file { '/etc/resolvconf/resolv.conf.d/tail':
  path    =>  '/etc/resolvconf/resolv.conf.d/tail',
  content =>  template("/vagrant/puppet/templates/tail.erb"),
  notify  =>  Service['resolvconf']
}

service { 'resolvconf':
  ensure => running
}

package { 'puppetmaster':
  ensure  => present,
  require => Package['puppet'],
  #require => Apt::Source['puppetlabs'],
}

package { 'puppetdb':
	ensure  => present,
	require => [ Apt::Source['puppetlabs'], Service['puppetmaster'], File['/etc/resolvconf/resolv.conf.d/tail']],
}

package { 'puppetdb-terminus':
	ensure  => present,
	require => [ Apt::Source['puppetlabs'], Service['puppetmaster']]
}

service { "puppetmaster":
  name       => "puppetmaster",
  ensure     => running,
  enable     => true,
  hasrestart => true,
  require    => Package["puppetmaster"],
}

service { "puppetdb":
  name       => "puppetdb",
  ensure     => running,
  enable     => true,
  hasrestart => true,
  require    => Package["puppetdb"],
}

# overwrite the default puppet.conf with template defined in our vagrant project
file { '/etc/puppet/puppet.conf':
  path    =>  '/etc/puppet/puppet.conf',
  content =>  template("/vagrant/puppet/templates/puppet_conf.erb"),
  notify  =>  Service['puppetmaster'],
}

# define the PuppetDB server’s hostname and port
file { '/etc/puppet/puppetdb.conf':
  path    =>  '/etc/puppet/puppetdb.conf',
  content =>  template("/vagrant/puppet/templates/puppetdb_conf.erb"),
  notify  =>  Service['puppetmaster'],
  require =>  Package['puppetmaster'],
}

file { '/opt/deploy':
	ensure => "directory"
}

# if the git repo requires authentication
if $git_auth_required == 'true' {
  file { '/root/.ssh':
    ensure => "directory"
  }
  file { '/root/.ssh/config':
    content     => "Host *\nStrictHostKeyChecking no",
    require     => File['/root/.ssh'],
  }
  file { '/root/.ssh/id_rsa':
    source      => "/vagrant/${git_id_rsa}",
    mode        => "400",
    require     => File['/root/.ssh'],
  }
  exec { 'checkout_manifests':
    cwd         => "/opt/deploy/",
    command     => "/usr/bin/git clone -b ${branch} ${giturl} .",
    creates     => "/opt/deploy/.git",
    require => [ File["/opt/deploy"], Package["git"], File['/root/.ssh/id_rsa'], File ['/root/.ssh/config'] ]
  }
}
else {
  exec { 'checkout_manifests':
    cwd         => "/opt/deploy/",
    command     => "/usr/bin/git clone -b ${branch} ${giturl} .",
    creates     => "/opt/deploy/.git",
    require => [ File["/opt/deploy"], Package["git"] ]
  }
}

package { 'r10k':
  ensure      => present,
  provider    => 'gem',
}

exec { 'build_pp_modules':
  cwd         => "/opt/deploy/",
  command     => "r10k puppetfile install",
  require     => [ Package["r10k"], Exec["checkout_manifests"] ]
}

exec { 'deploy_site_pp':
	cwd     => "/opt/deploy/manifests",
	command => "/bin/cp /opt/deploy/$deploy_site_pp /opt/deploy/manifests/site.pp",
	notify	=> Service[ 'puppetmaster'],
	require => Exec['checkout_manifests']
}