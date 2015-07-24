#!/usr/bin/env bash
# Install and configure dependences for dev specific to the ODL Puppet mod

# Install system-level software dependences
config.vm.provision "shell", inline: "yum install -y git vim rubygems ruby-devel gcc-c++ zlib-devel patch"

config.vm.provision "shell", inline: "gem install bundler"
# Unexpectedly, /usr/local/bin isn't in the default path. Add for Bundler.
config.vm.provision "shell", inline: "echo export PATH=$PATH:/usr/local/bin >> /home/vagrant/.bashrc"
# TODO: Hack, but it works. Clean it up.
config.vm.provision "shell", inline: "cd /vagrant/puppet-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"


  # Update the system. Required for `gem install bundler`.
  #config.vm.provision "shell", inline: "yum update -y"

