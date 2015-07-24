# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Start with a common CentOS 7 Vagrant base box
  # This one supports a VBox provider and has guest additions installed
  config.vm.box = "chef/centos-7.0"

  # TODO: Docs
  config.vm.define "centos" do |centos|
    # Start with a common CentOS 7 Vagrant base box
    # This one supports a VBox provider and has guest additions installed
    centos.vm.box = "chef/centos-7.0"

    # It doesn't seem that there are packaged headers for kernel-3.10.0-123,
    #   so we need to update the kernel and install matching headers. While
    #   we're updating the kernel, we'll just update everything.
    centos.vm.provision "shell", inline: "yum update -y"

    # May need to install DKMS first, to get a rebuild of the VBox kernel
    #   module when we get a kernel upgrade via `yum update`.
    centos.vm.provision "shell", inline: "yum install -y dkms gcc kernel-devel"

    # Install/update VirtualBox Guest Additions for the new kernel
    centos.vm.provision "shell", inline: "mount /vagrant/cache/VBoxGuestAdditions_5.0.0.iso /mnt/"
    # This "fails" when X isn't installed, which is a false neg for us.
    #   Appending `; true` forces a 0 exit status, letting Vagrant continue.
    centos.vm.provision "shell", inline: "/mnt/VBoxLinuxAdditions.run; true"
    #centos.vm.provision "shell", inline: ""
    
    # Need to reboot for kernel update to work on 3.x Linux
    # NB: The host OS must have the vagrant-reload plugin installed
    # TODO: This will fail because Guest Additions are out-of-sync
    centos.vm.provision :reload

    # Install Vagrant
    centos.vm.provision "shell", inline: "yum localinstall -y https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.rpm"
  end

  config.vm.define "fedora" do |fedora|
    # Work from a Fedora 21 base box
    fedora.vm.box = "boxcutter/fedora21"

    # Ensure cache of large artifacts is populated
    # (this is related to a tutorial I'm doing)
    fedora.vm.provision "shell", inline: "yum install -y git"
    #fedora.vm.provision "shell", path: "cache/cache.sh /vagrant/cache/"
    fedora.vm.provision "shell" do |s|
      s.path = "cache/cache.sh"
      s.args = "/vagrant/cache/"
    end

    # Install Vagrant
    fedora.vm.provision "shell", inline: "yum localinstall -y /vagrant/cache/vagrant_1.7.4_x86_64.rpm"

    # Install VirtualBox from the RPMFusion repos
    fedora.vm.provision "shell", inline: "yum localinstall -y /vagrant/cache/rpmfusion-free-release-21.noarch.rpm"
    # TODO: Cache this
    # https://access.redhat.com/solutions/10154
    fedora.vm.provision "shell", inline: "yum install -y VirtualBox kmod-VirtualBox"

    # Need to reboot for kmod-VBox update to work on 3.x Linux
    # NB: The host OS must have the vagrant-reload plugin installed
    fedora.vm.provision :reload

    # Install Puppet system-level software dependences
    # TODO: Cache this
    fedora.vm.provision "shell", inline: "yum install -y git vim rubygems ruby-devel gcc-c++ zlib-devel patch"

    # Install bundler and configure the `vagrant` user's path to include it
    # Must update OpenSSL for gem/bundler/etc SSL cert checks to pass
    # TODO: Is that^^ right?
    fedora.vm.provision "shell", inline: "yum update -y openssl"
    fedora.vm.provision "shell", inline: "gem install bundler"
    fedora.vm.provision "shell", inline: "echo export PATH=$PATH:/usr/local/bin >> /home/vagrant/.bashrc"

    # Do the actual `bundle install` step to install most Puppet deps
    # TODO: Hack, but it works. Clean it up.
    #   The hack relates to needing to run as the `vagrant` user and needing
    #   the path update above to work.
    fedora.vm.provision "shell", inline: "cd /vagrant/puppet-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"

    # NB: Everything above here currently works

    # TODO: Do everything related to the RPM
    # Install required RPM building software and the repo that serves it
    # TODO: Cache
    fedora.vm.provision "shell", inline: "yum install -y fedora-packager"

    # TODO: Do everything related to the Ansible role
    # Install Ansible and the `ansible-galaxy` tool
    fedora.vm.provision "shell", inline: "yum install -y ansible"

    # Install ODL's Ansible role
    fedora.vm.provision "shell", inline: "ansible-galaxy install dfarrell07.opendaylight"

    # TODO: Provision a (TBD creation) 32 bit box via vagrant-odl and Ansible

    # TODO: Do everything related to vagrant-opendaylight
    # TODO: `vagrant box add` the relevant Vagrant boxes via the cache

    # TODO: Do everything related to the Dockerfile
    # Install Docker
    # TODO: Cache this
    fedora.vm.provision "shell", inline: "yum localinstall -y https://get.docker.com/rpm/1.7.1/fedora-21/RPMS/x86_64/docker-engine-1.7.1-1.fc21.x86_64.rpm"

    # Start the Docker daemon
    fedora.vm.provision "shell", inline: "service docker start"

    # TODO: Cache debian:7 Docker image, use local version
    fedora.vm.provision "shell", inline: "docker pull debian:7"

    # TODO: Try to install stuff for Packer? I lean towards no.

    #fedora.vm.provision "shell", inline: ""
    #fedora.vm.provision "shell", inline: ""
  end


  # TODO: Docs
  config.vm.define "pakdep" do |pakdep|
    pakdep.vm.box = "dfarrell07/pakdep"
  end

end
