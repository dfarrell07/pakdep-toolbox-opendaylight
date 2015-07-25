# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Work from a Fedora 21 base box
  config.vm.box = "boxcutter/fedora21"

  # OpenDaylight packaging and deployment toolbox
  config.vm.define "pakdep" do |pakdep|
    # Update the system
    pakdep.vm.provision "shell", inline: "yum update -y"

    #
    # Install/config related to RPM building
    #

    # Install required RPM building software and the repo that serves it
    pakdep.vm.provision "shell", inline: "yum install -y fedora-packager"

    # Install dependencies of RPM build.sh and install.sh scripts
    pakdep.vm.provision "shell", inline: "yum install -y java sshpass"

    #
    # Install/config related to the Ansible role
    #

    # Install Ansible and the `ansible-galaxy` tool
    pakdep.vm.provision "shell", inline: "yum install -y ansible"

    # Install ODL's Ansible role
    pakdep.vm.provision "shell", inline: "ansible-galaxy install dfarrell07.opendaylight"

    #
    # Install/config related to the Puppet module
    #

    # Install Puppet system-level software dependences
    pakdep.vm.provision "shell", inline: "yum install -y git rubygems ruby-devel gcc-c++ zlib-devel patch"

    # Install bundler and configure the `vagrant` user's path to include it
    pakdep.vm.provision "shell", inline: "gem install bundler"
    pakdep.vm.provision "shell", inline: "echo \'export PATH=$PATH:/usr/local/bin\' >> /home/vagrant/.bashrc; su -c \"source ~/.bashrc\""
    # TODO: Verify this^^

    # Do the actual `bundle install` step to install most Puppet deps
    # TODO: Hack, but it works. Clean it up.
    #   The hack relates to needing to run as the `vagrant` user and needing
    #   the path update above to work.
    pakdep.vm.provision "shell", inline: "cd /vagrant/puppet-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"

    # Install the ODL Puppet mod system-wide
    cached.vm.provision "shell", inline: "su -c \"source ~/.bashrc; puppet module install dfarrell07-opendaylight\" vagrant"
    # TODO: Verify this^^

    #
    # Install/config related to vagrant-opendaylight
    #

    # Use the Gemfile in vagrant-opendaylight to install its Gem dependencies
    cached.vm.provision "shell", inline: "cd /vagrant/vagrant-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"
    # TODO: Verify this^^

    # Add librarian-puppet to the path of the `vagrant` user
    cached.vm.provision "shell", inline: "echo \'export PATH=$PATH:/home/vagrant/bin\' >> /home/vagrant/.bashrc"
    # TODO: Verify this^^

    # Install the Puppet module dependences of vagrant-odl via librarian-puppet
    cached.vm.provision "shell", inline: "cd /vagrant/vagrant-opendaylight; su -c \"source ~/.bashrc; librarian-puppet install\" vagrant"
    # TODO: Verify this^^

    #
    # Install/config related to Docker
    #

    # Install Docker
    pakdep.vm.provision "shell", inline: "yum localinstall -y https://get.docker.com/rpm/1.7.1/fedora-21/RPMS/x86_64/docker-engine-1.7.1-1.fc21.x86_64.rpm"

    # Start the Docker daemon
    pakdep.vm.provision "shell", inline: "service docker start"
    pakdep.vm.provision "shell", inline: "chkconfig docker on"

    # Add vagrant user Docker's group so it can run `docker` without sudo
    # NB: This requires a reboot to take effect
    pakdep.vm.provision "shell", inline: "usermod -aG docker vagrant"

    # Cache some Docker images
    pakdep.vm.provision "shell", inline: "docker pull debian:7"
    pakdep.vm.provision "shell", inline: "docker pull centos:7"
    pakdep.vm.provision "shell", inline: "docker pull fedora:21"
    pakdep.vm.provision "shell", inline: "docker pull fedora:22"
    pakdep.vm.provision "shell", inline: "docker pull dfarrell07/odl"

    # Build ODL's Docker image
    # It does major downloads, like Java and ODL, which we need to have cached
    pakdep.vm.provision "shell", inline: "cd /vagrant/integration/packaging/docker/; docker build -t odl:0.2.3 ."

    #
    # Install/config related to Vagrant
    #

    # Install Vagrant
    pakdep.vm.provision "shell", inline: "yum localinstall -y https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.rpm"

    # Install VirtualBox from the RPMFusion repos
    pakdep.vm.provision "shell", inline: "yum localinstall -y http://download1.rpmfusion.org/free/fedora/$rpmfusion_rpm/rpmfusion-free-release-21.noarch.rpm"
    # NB: This requires a reboot to take effect
    pakdep.vm.provision "shell", inline: "yum install -y VirtualBox kmod-VirtualBox"

    #
    # General system configuration
    #

    # Install a basic set of dev tools
    pakdep.vm.provision "shell", inline: "yum install -y vim nano @development-tools"

    # Ensure cache of large artifacts is populated
    # (this is related to a tutorial I'm doing)
    #pakdep.vm.provision "shell", inline: "yum install -y git"
    #pakdep.vm.provision "shell", path: "cache/cache.sh /vagrant/cache/"
    pakdep.vm.provision "shell" do |s|
      s.path = "cache/cache.sh"
      s.args = "/vagrant/cache/"
    end

    #
    # Reboot the system
    #

    # Need to reboot for:
    #   * kmod-VBox update to work on 3.x Linux
    #   * Addition of `vagrant` user to `docker` group to work
    # NB: The host OS must have the vagrant-reload plugin installed
    pakdep.vm.provision :reload

    #
    # Post-reboot tasks
    #

    # Cache 32 bit Vagrant base box
    # This has to happen after the reboot because Vagrant breaks until its
    #   kernel module update takes effect, and that requires a reboot.
    # TODO: Verify that's true^^
    pakdep.vm.provision "shell", inline: "su -c \"vagrant box add boxcutter/fedora21-i386\""
  end


  # Version of the above pakdep box that has been cached via `vagrant package`
  config.vm.define "cached" do |cached|
    cached.vm.box = "dfarrell07/pakdep"

    # Use the Gemfile in vagrant-opendaylight to install its Gem dependencies
    cached.vm.provision "shell", inline: "cd /vagrant/vagrant-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"

    # Add librarian-puppet to the path of the `vagrant` user
    cached.vm.provision "shell", inline: "echo \'export PATH=$PATH:/home/vagrant/bin\' >> /home/vagrant/.bashrc"

    # Install the Puppet module dependences of vagrant-odl via librarian-puppet
    cached.vm.provision "shell", inline: "cd /vagrant/vagrant-opendaylight; su -c \"source ~/.bashrc; librarian-puppet install\" vagrant"

    # Install the ODL Puppet mod system-wide
    cached.vm.provision "shell", inline: "su -c \"source ~/.bashrc; puppet module install dfarrell07-opendaylight\" vagrant"
  end
end
