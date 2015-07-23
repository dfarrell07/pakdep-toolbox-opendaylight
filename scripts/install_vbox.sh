#!/usr/bin/env bash


# Install VirtualBox and its kernel module
# TODO: Clean this up, minimize it
# Via: http://goo.gl/aVQlq3
yum install -y epel-release
yum install -y kernel-devel kernel-headers dkms
yum groupinstall -y \"Development Tools\"
yum update -y
wget http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc
rpm --import oracle_vbox.asc
wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo
yum install -y VirtualBox-4.3
service vboxdrv setup
usermod -a -G vboxusers vagrant
