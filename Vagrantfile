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
    pakdep.vm.provision "shell", inline: "ansible-galaxy install dfarrell07.opendaylight --force"

    #
    # Install/config related to the Puppet module
    #

    # Install Puppet system-level software dependences
    pakdep.vm.provision "shell", inline: "yum install -y git rubygems ruby-devel gcc-c++ zlib-devel patch"

    # Install bundler and configure the `vagrant` user's path to include it
    pakdep.vm.provision "shell", inline: "gem install bundler"
    pakdep.vm.provision "shell", inline: "echo \'export PATH=$PATH:/usr/local/bin\' >> /home/vagrant/.bashrc; su -c \"source ~/.bashrc\" vagrant"
    # TODO: Is that^^ `source` step required?

    # Do the actual `bundle install` step to install most Puppet deps
    # TODO: Hack, but it works. Clean it up.
    #   The hack relates to needing to run as the `vagrant` user and needing
    #   the path update above to work.
    pakdep.vm.provision "shell", inline: "cd /vagrant/puppet-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"

    # Install the ODL Puppet mod system-wide
    pakdep.vm.provision "shell", inline: "su -c \"/home/vagrant/bin/puppet module install dfarrell07-opendaylight\" vagrant"

    #
    # Install/config related to vagrant-opendaylight
    #

    # Use the Gemfile in vagrant-opendaylight to install its Gem dependencies
    pakdep.vm.provision "shell", inline: "cd /vagrant/vagrant-opendaylight; su -c \"source ~/.bashrc; bundle install\" vagrant"

    # Add librarian-puppet to the path of the `vagrant` user
    pakdep.vm.provision "shell", inline: "echo \'export PATH=$PATH:/home/vagrant/bin\' >> /home/vagrant/.bashrc"

    # Install the Puppet module dependences of vagrant-odl via librarian-puppet
    pakdep.vm.provision "shell", inline: "cd /vagrant/vagrant-opendaylight; su -c \"source ~/.bashrc; librarian-puppet install\" vagrant"

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
    pakdep.vm.provision "shell", inline: "su -c \"vagrant box add boxcutter/fedora21-i386\" vagrant"
  end


  # Version of the above pakdep box that has been cached via `vagrant package`
  config.vm.define "cached" do |cached|
    cached.vm.box = "pakdep"
    # Remove old lock file (shouldn't have been cached in v0.1.0) if it exits
    cached.vm.provision "shell", inline: "rm /vagrant/.git/modules/puppet-opendaylight/index.lock; true"

    # Change /vagrant/.git/config to use HTTPS URL
    cached.vm.provision "shell", inline: "sed -ri 's/git@github.com:/https:\\/\\/github.com\\//' /vagrant/.git/config"

    # Install tree, very useful for browsing source
    cached.vm.provision "shell", inline: "yum install -y tree"

    # TODO: Pull updates to pakdep repo from /vagrant
    #cached.vm.provision "shell", inline: "cd /vagrant; su -c \"git pull\" vagrant"
    # Not sure this^^ makese sense, the Vagrantfile updating itself
    # TODO: Checkout a dev branch of puppet-opendaylight to get local RPM install

    # Update git submodules
    cached.vm.provision "shell", inline: "cd /vagrant; su -c \"git submodule update --remote integration\""
    cached.vm.provision "shell", inline: "cd /vagrant; su -c \"git submodule update --remote puppet-opendaylight\""
    cached.vm.provision "shell", inline: "cd /vagrant; su -c \"git submodule update --remote ansible-opendaylight\""
    cached.vm.provision "shell", inline: "cd /vagrant; su -c \"git submodule update --remote vagrant-opendaylight\""

    # Update our system-wide install of the ODL Ansible role
    cached.vm.provision "shell", inline: "ansible-galaxy install dfarrell07.opendaylight --force"
    # Could also^^ rsync from /vagrant/ansible-opendaylight
    #cached.vm.provision "shell", inline: "rsync -r /vagrant/ansible-opendaylight/* /etc/ansible/roles/dfarrell07.opendaylight/"

    # Do minimal Puppet install steps as root as well
    # `puppet apply` requires running as root using the yum module
    # TODO: One of these hung once?
    #cached.vm.provision "shell", inline: "gem install puppet"
    #cached.vm.provision "shell", inline: "/home/vagrant/bin/puppet module install dfarrell07-opendaylight"
    # TODO: Add back once we have Puppet local install support
  end
end
