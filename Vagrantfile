# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
vagrant_dir = File.expand_path(File.dirname(__FILE__))

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  vagrant_version = Vagrant::VERSION.sub(/^v/, '')

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |vb|
    # vb.gui = true
    vb.customize ["modifyvm", :id, "--memory", "512"]

    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.hostname = "wp.local"
  config.vm.network "private_network", ip: "192.168.50.2"

  config.vm.provision "software", type: "shell", :path => "provision/software.sh"
  config.vm.provision "configs", type: "shell", :path => "provision/configs.sh", run: "always"


  if vagrant_version >= "1.3.0"
    config.vm.synced_folder "www/", "/srv/www/", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
  else
    config.vm.synced_folder "www/", "/srv/www/", :owner => "www-data", :extra => 'dmode=775,fmode=774'
  end
  config.vm.synced_folder "config", "/srv/config"
  config.vm.synced_folder "log", "/srv/log", :owner => "www-data"

  if defined?(VagrantPlugins::HostsUpdater)
    paths = Dir[File.join(vagrant_dir, 'www', '**', 'hosts')]

    hosts = paths.map do |path|
      lines = File.readlines(path).map(&:chomp)
      lines.grep(/\A[^#]/)
    end.flatten.uniq # Remove duplicate entries

    # Pass the found host names to the hostsupdater plugin so it can perform magic.
    config.hostsupdater.aliases = hosts
    config.hostsupdater.remove_on_suspend = true
  end

end
