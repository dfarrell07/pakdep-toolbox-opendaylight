#!/usr/bin/env bash
# Install VirtualBox and its dependencies
# TODO: Clean this up, minimize it
# Via: http://goo.gl/aVQlq3

# It doesn't seem that there are packaged headers for kernel-3.10.0-123,
#   so we need to update the kernel and install matching headers. While
#   we're updating the kernel, we'll just update everything.
yum update -y

# Now that we've updated the kernel, install kernel headers and such
yum install -y kernel-devel kernel-headers dkms

# Need to reboot for kernel update to work on 3.x Linux
# TODO: idk if this works
reboot

yum groupinstall -y \"Development Tools\"
wget http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
rpm --import oracle_vbox.asc
wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
yum install -y VirtualBox-4.3
service vboxdrv setup
usermod -a -G vboxusers vagrant
