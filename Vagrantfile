# -*- mode: ruby -*-
# vi: set ft=ruby :

# Usage: ENV=staging vagrant up

VAGRANTFILE_API_VERSION = "2"

require 'json'

localConf = JSON.parse(File.read('VagrantConfig.json'))

environment = "development"
if ENV["ENV"] && ENV["ENV"] != ''
    environment = ENV["ENV"].downcase
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provision :shell, :path => "puppet_bootstrap.sh"

    if environment == 'development'
      config.vm.box = "precise64"
      config.vm.box_url = "http://files.vagrantup.com/precise64.box"

      config.vm.network :forwarded_port, guest: 80,    host: 10080    # apache http
      config.vm.network :forwarded_port, guest: 3306,  host: 3306  # mysql
      config.vm.network :forwarded_port, guest: 10081, host: 10081 # zend http
      config.vm.network :forwarded_port, guest: 10082, host: 10082 # zend https

      config.vm.network :private_network, ip: localConf['ipAddress']

        config.vm.provider :virtualbox do |vb, override|

            vb.gui = false
            vb.customize ["modifyvm", :id, "--memory", localConf['vmMemory']]
            vb.customize ["modifyvm", :id, "--cpuexecutioncap", "90"]
            vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant-root", "1"]


            host = RbConfig::CONFIG['host_os']

            if host =~ /darwin/
               cpus = `sysctl -n hw.ncpu`.to_i
            elsif host =~ /linux/
               cpus = `nproc`.to_i
            else
               cpus = 2
            end

            vb.customize ["modifyvm", :id, "--cpus", cpus]
            config.vm.synced_folder ".", "/vagrant",  nfs: true
        end

        config.vm.provision :puppet do |puppet|
            puppet.options        = "--verbose --debug"
            puppet.manifests_path = "puppet/manifests"
            puppet.module_path    = "puppet/modules"
            puppet.manifest_file  = "site.pp"
            puppet.facter         = {
                "vagrant"     => true,
                "environment" => environment,
                "site_domain" => localConf['siteDomain'],
                "role"        => "local",
                "php_version" => localConf['phpVersion']
            }
        end
    end

end
