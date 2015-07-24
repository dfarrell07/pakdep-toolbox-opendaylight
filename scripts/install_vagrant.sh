# Install Vagrant
yum localinstall -y https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.rpm

# Install a plugin that will update the VBox Guest Additions version
#   of Vagrant boxes that we start *from/inside* the pakdep Vagrant box.
vagrant plugin install vagrant-vbguest
