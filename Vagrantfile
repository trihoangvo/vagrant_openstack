# -*- mode: ruby -*-
# vi: set ft=ruby :
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
#
# Vagrantfile bring up openStack VMs

require "yaml"
require 'net/http'

_config = YAML.load(File.open(File.join(File.dirname(__FILE__),
                    "config.yaml"), File::RDONLY).read)
CONF = _config

# global configurations
$base_box_url  = CONF['base_box_url']
$base_box_name = CONF['base_box_name']
$env           = CONF['env']

# caching
if CONF['cache_enabled'] == true
  if CONF['cache_dir'].nil?
    cache_dir = "#{Dir.pwd}/cache"
  else
    cache_dir = CONF['cache_dir']
  end
  unless File.exists?(cache_dir)
    Dir.mkdir(cache_dir)
  end
  cache_img_file = "#{cache_dir}/#{CONF['cache_img_name']}"
  puts "Cache enabled: #{cache_dir}"
  if $env == "puppet" and not File.exist?(cache_img_file)
    uri = URI(CONF['cache_img_get'])
    puts "#{CONF['cache_img_name']} not exists, start download from #{uri.host}"
         " Please wait.."
    Net::HTTP.start(uri.host) { |http|
      resp = http.get(uri.path)
      open(cache_img_file, "wb") { |file|
       file.write(resp.body)
      }
    }
  end
end

Vagrant.configure("2") do |config|
  # network ranges configuration
  network = {
    :mgt          => CONF['private_mgt_net'],
    :private_data => CONF['private_data_net'],
    :public1      => CONF['public_net1'],
    :public2      => CONF['public_net2']
  }

  # nodes configuration
  nodes = {
    :puppet => {
      :hostname => "#{CONF['puppet_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['puppet_ip']}",
      :cpu      => CONF['puppet_cpu'],
      :ram      => CONF['puppet_ram']
    },
    :control => {
      :hostname => "#{CONF['control_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['control_ip']}",
      :cpu      => CONF['control_cpu'],
      :ram      => CONF['control_ram']
    },
    :compute1 => {
      :hostname => "#{CONF['compute1_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['compute1_ip']}",
      :ip_data  => "#{network[:private_data]}#{CONF['compute1_ip']}",
      :cpu      => CONF['compute1_cpu'],
      :ram      => CONF['compute1_ram']
    },
    :compute2 => {
      :enabled  => CONF['compute2_enabled'],
      :hostname => "#{CONF['compute2_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['compute2_ip']}",
      :ip_data  => "#{network[:private_data]}#{CONF['compute2_ip']}",
      :cpu      => CONF['compute2_cpu'],
      :ram      => CONF['compute2_ram']
    },
    :neutron1 => {
      :hostname => "#{CONF['neutron1_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['neutron1_ip']}",
      :ip_data  => "#{network[:private_data]}#{CONF['neutron1_ip']}",
      :ip_pub   => "#{network[:public1]}#{CONF['neutron1_public_ip']}",
      :cpu      => CONF['neutron1_cpu'],
      :ram      => CONF['neutron1_ram']
    },
    :neutron2 => {
      :enabled  => CONF['neutron2_enabled'],
      :hostname => "#{CONF['neutron2_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['neutron2_ip']}",
      :ip_data  => "#{network[:private_data]}#{CONF['neutron2_ip']}",
      :ip_pub   => "#{network[:public2]}#{CONF['neutron2_public_ip']}",
      :cpu      => CONF['neutron2_cpu'],
      :ram      => CONF['neutron2_ram']
    },
    :monitor => {
      :enabled  => CONF['monitor_enabled'],
      :hostname => "#{CONF['monitor_hostname']}.#{CONF['domain']}",
      :ip_mgt   => "#{network[:mgt]}#{CONF['monitor_ip']}",
      :cpu      => CONF['monitor_cpu'],
      :ram      => CONF['monitor_ram']
    }
  }

  # select git respository for the given environment
  case $env
  when "devstack"
    env_alias = "dev" 
    branch    = CONF['devstack_branch']
    vm_cache  = "/var/cache/pip"
  when "puppet"
    env_alias = "pp" 
    branch    = CONF['puppet_branch']
    vm_cache  = "/var/cache/apt/archives"
  end

  puts "Working on environment deployed by "\
    "#{$env} branch #{branch}..."

  # puppet facters pass to nodes here
  facter = {
    :puppet => {
      "giturl"               => CONF['puppet_giturl'],
      "branch"               => CONF['puppet_branch'],
      "deploy_site_pp"       => CONF['puppet_site_pp'],
      "env"                  => $env,
      "puppet_cloudarchive"  => CONF['puppet_cloudarchive'],
      "git_auth_required"    => CONF['git_auth_required'],
      "git_id_rsa"           => CONF['git_id_rsa'],
      },
    :control => {
      # tenant network
      "private_net_range"    => CONF['private_net_range'],
      "public_net_name"      => CONF['public_net_name'],
      "public_net_range"     => "#{network[:public1]}0/24",
      "public_net_gateway"   => nodes[:neutron1][:ip_pub],
      "pool_start"           => "#{network[:public1]}#{CONF['pool_start']}",
      "pool_end"             => "#{network[:public1]}#{CONF['pool_end']}",
      "env"                  => $env,
      "puppet_cloudarchive"  => CONF['puppet_cloudarchive'],
      "devstack_git_url"     => CONF['devstack_git_url'],
      "devstack_branch"      => CONF['devstack_branch'],
      "openstack_branch"     => CONF['openstack_branch'],
      "devstack_img_name"    => CONF['cache_img_name'],
      "devstack_img_urls"    => CONF['cache_img_get'],
    },
    :neutron1 => {
      "public_net_gateway"   => nodes[:neutron1][:ip_pub],
      "public_net_interface" => CONF['public_net_interface'],
      "public_net_range"     => "#{network[:public1]}0/24",
      "env"                  => $env,
      "puppet_cloudarchive"  => CONF['puppet_cloudarchive'],
      "devstack_git_url"     => CONF['devstack_git_url'],
      "devstack_branch"      => CONF['devstack_branch'],
      "openstack_branch"     => CONF['openstack_branch'],
    },
    :neutron2 => {
      "public_net_gateway"   => nodes[:neutron2][:ip_pub],
      "public_net_interface" => CONF['public_net_interface'],
      "public_net_range"     => "#{network[:public2]}0/24",
      "env"                  => $env,
      "puppet_cloudarchive"  => CONF['puppet_cloudarchive'],
      "devstack_git_url"     => CONF['devstack_git_url'],
      "devstack_branch"      => CONF['devstack_branch'],
      "openstack_branch"     => CONF['openstack_branch'],
    },
    :compute => {
      "env"                  => $env,
      "puppet_cloudarchive"  => CONF['puppet_cloudarchive'],
      "devstack_git_url"     => CONF['devstack_git_url'],
      "devstack_branch"      => CONF['devstack_branch'],
      "openstack_branch"     => CONF['openstack_branch'],
    }
  }

  # define puppet node
  if $env == "puppet"
    config.vm.define :puppet do |puppet_server_config|
      puppet_server_config.vm.hostname = nodes[:puppet][:hostname]
      puppet_server_config.vm.box = $base_box_name
      puppet_server_config.vm.box_url = $base_box_url
      if CONF['cache_enabled'] == true
        puppet_server_config.vm.synced_folder cache_dir, vm_cache
      end
      puppet_server_config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", nodes[:puppet][:cpu]]
        vb.customize ["modifyvm", :id, "--memory", nodes[:puppet][:ram]]
      end

      # network configuration
      puppet_server_config.vm.network :private_network, \
        ip: nodes[:puppet][:ip_mgt]

      # enable provisioning via puppet
      puppet_server_config.vm.provision :puppet do |puppet|
        # set manifests directory
        puppet.manifests_path = "puppet/manifests"
        # select manifest
        puppet.manifest_file = "puppetmaster.pp"
        # set the module path
        puppet.module_path = "puppet/modules"
        puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
        puppet.facter = facter[:puppet]
      end
    end
  else
    printf "%-24s %s\n", "puppet", "disabled in config.yaml"
  end

  # define control node
  config.vm.define :"control.#{env_alias}" do |control_config|
    control_config.vm.hostname = nodes[:control][:hostname]
    control_config.vm.box = $base_box_name
    control_config.vm.box_url = $base_box_url
    if CONF['cache_enabled'] == true
      control_config.vm.synced_folder cache_dir, vm_cache
    end
    control_config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", nodes[:control][:cpu]]
      vb.customize ["modifyvm", :id, "--memory", nodes[:control][:ram]]

      # location of virtual storage used by cinder
      if CONF['cinder_storage_dir'].nil?
        CONF['cinder_storage_dir'] = "#{ENV['HOME']}/VirtualBox\ VMs"
      end
      vdi = "#{CONF['cinder_storage_dir']}/#{CONF['cinder_storage_file']}_#{$env}.vdi"
      # create virtual storage
      vb.customize ["createhd", "--filename", vdi, 
                    "--size", CONF['cinder_storage_size']]
      # attach virtual storage to vm
      vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", 
                    "--port", 1, "--device", 0, "--type", "hdd", "--medium", vdi]
    end
    
    # network configuration
    control_config.vm.network :private_network, \
      ip: nodes[:control][:ip_mgt]
    control_config.vm.network :forwarded_port, guest: 80, host: 1337
    #enable provisioning via puppet
    control_config.vm.provision :puppet do |puppet|
      #set manifests directory
      puppet.manifests_path = "puppet/manifests"
      #select manifest
      puppet.manifest_file = "control.pp"
      #set the module path
      puppet.module_path = "puppet/modules"
      puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
      puppet.facter = facter[:control]
    end
  end

  # define compute node 1
  config.vm.define :"compute1.#{env_alias}" do |compute_config|
    compute_config.vm.hostname = nodes[:compute1][:hostname]
    compute_config.vm.box = $base_box_name
    compute_config.vm.box_url = $base_box_url
    if CONF['cache_enabled'] == true
      compute_config.vm.synced_folder cache_dir, vm_cache
    end
    compute_config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", nodes[:compute1][:cpu]]
      vb.customize ["modifyvm", :id, "--memory", nodes[:compute1][:ram]]
    end
    # network configuration
    compute_config.vm.network :private_network, \
      ip: nodes[:compute1][:ip_mgt]
    compute_config.vm.network :private_network, \
      ip: nodes[:compute1][:ip_data]

    # enable provisioning via puppet
    compute_config.vm.provision :puppet do |puppet|
      #set manifests directory
      puppet.manifests_path = "puppet/manifests"
      #select manifest
      puppet.manifest_file = "compute.pp"
      #set the module path
      puppet.module_path = "puppet/modules"
      puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
      puppet.facter = facter[:compute]
    end
  end

  # define compute node 2
  if nodes[:compute2][:enabled] == true
    config.vm.define :"compute2.#{env_alias}" do |compute_config|
      compute_config.vm.hostname = nodes[:compute2][:hostname]
      compute_config.vm.box = $base_box_name
      compute_config.vm.box_url = $base_box_url
      if CONF['cache_enabled'] == true
        compute_config.vm.synced_folder cache_dir, vm_cache
      end
      compute_config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", nodes[:compute2][:cpu]]
        vb.customize ["modifyvm", :id, "--memory", nodes[:compute2][:ram]]
      end
      # network configuration
      compute_config.vm.network :private_network, \
        ip: nodes[:compute2][:ip_mgt]
      compute_config.vm.network :private_network, \
        ip: nodes[:compute2][:ip_data]

      # enable provisioning via puppet
      compute_config.vm.provision :puppet do |puppet|
        #set manifests directory
        puppet.manifests_path = "puppet/manifests"
        #select manifest
        puppet.manifest_file = "compute.pp"
        #set the module path
        puppet.module_path = "puppet/modules"
        puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
        puppet.facter = facter[:compute]
      end
    end
  else
    printf "%-24s %s\n", "compute2.#{env_alias}", "disabled in config.yaml"
  end

  # define network node 1
  config.vm.define :"neutron1.#{env_alias}" do |network_config|
    network_config.vm.hostname = nodes[:neutron1][:hostname]
    network_config.vm.box = $base_box_name
    network_config.vm.box_url = $base_box_url
    if CONF['cache_enabled'] == true
      network_config.vm.synced_folder cache_dir, vm_cache
    end
    network_config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--cpus", nodes[:neutron1][:cpu]]
      vb.customize ["modifyvm", :id, "--memory", nodes[:neutron1][:ram]]
      vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
    end
    # network configuration
    network_config.vm.network :private_network, \
      ip: nodes[:neutron1][:ip_mgt]
    network_config.vm.network :private_network, \
      ip: nodes[:neutron1][:ip_data]
    network_config.vm.network :private_network, \
      ip: nodes[:neutron1][:ip_pub]

    #enable provisioning via puppet
    network_config.vm.provision :puppet do |puppet|
      #set manifests directory
      puppet.manifests_path = "puppet/manifests"
      #select manifest
      puppet.manifest_file = "neutron.pp"
      #set the module path
      puppet.module_path = "puppet/modules"
      puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
      puppet.facter = facter[:neutron1]
    end
  end

  # define network node 2
  if nodes[:neutron2][:enabled] == true
    config.vm.define :"neutron2.#{env_alias}" do |network_config|
      network_config.vm.hostname = nodes[:neutron2][:hostname]
      network_config.vm.box = $base_box_name
      network_config.vm.box_url = $base_box_url
      if CONF['cache_enabled'] == true
        network_config.vm.synced_folder cache_dir, vm_cache
      end
      network_config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", nodes[:neutron2][:cpu]]
        vb.customize ["modifyvm", :id, "--memory", nodes[:neutron2][:ram]]
        vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
      end
      # network configuration
      network_config.vm.network :private_network, \
        ip: nodes[:neutron2][:ip_mgt]
      network_config.vm.network :private_network, \
        ip: nodes[:neutron2][:ip_data]
      network_config.vm.network :private_network, \
        ip: nodes[:neutron2][:ip_pub]

      #enable provisioning via puppet
      network_config.vm.provision :puppet do |puppet|
        #set manifests directory
        puppet.manifests_path = "puppet/manifests"
        #select manifest
        puppet.manifest_file = "neutron.pp"
        #set the module path
        puppet.module_path = "puppet/modules"
        puppet.options = "--hiera_config /vagrant/files/hiera.yaml"
        puppet.facter = facter[:neutron2]
      end
    end
  else
    printf "%-24s %s\n", "neutron2.#{env_alias}", "disabled in config.yaml"
  end

end
