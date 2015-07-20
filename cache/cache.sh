#/usr/bin/env sh
# TODO: Docs

# Echo commands as they are run
set -x

mode="basic"

# NB: These will need to be updated for version bumps
odl_version="0.3.0-Lithium"

# Common names used in this script
odl_tarball="distribution-karaf-$odl_version.tar.gz"
vagrant_box="chef-centos-7.0-virtualbox-1.0.0.box"
centos_iso="CentOS-7-x86_64-Minimal-1503-01.iso"

# Common paths used in this script
# TODO: Smarter cache paths
odl_tb_cache_path="$odl_tarball"
vagrant_box_cache_path="$vagrant_box"
centos_iso_cache_path="$centos_iso"
odl_tb_url="https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/$odl_version/$odl_tarball"
centos_iso_url="http://mirrors.seas.harvard.edu/centos/7/isos/x86_64/$centos_iso"


cache_odl_tb()
{
  # Download ODL release tarball if it's not cached locally
  if [ ! -f  $odl_tb_cache_path ]; then
    echo "No cached ODL found, downloading from Nexus..."
    curl -o $odl_tb_cache_path $odl_tb_url
  else
    echo "Using cached version of ODL at $odl_tb_cache_path"
  fi
}

cache_vagrant_box()
{
  # Download a CentOS Vagrant base box if it's not cached locally
  if [ ! -f $vagrant_box_cache_path]; then
    # Download a CentOS 7 Vagant base box if it's not cached by Vagrant
    vagrant box add --provider virtualbox chef/centos-7.0

    # Build a .box file from the unpacked local version added above. Vagrant
    #   doesn't have a way to pull .box files without unpacking them, so two steps.
    vagrant box repackage chef/centos-7.0 virtualbox 1.0.0
    mv package.box $vagrant_box_cache_path

    # Confirm the CentOS Vagrant base box was output to expected location
    if [ -f  $vagrant_box_cache_path ]; then
      echo "Vagrant box cached: $vagrant_box_cache_path"
    else
      echo "Failed to cache Vagrant box!"
      echo "Expected Vagrant box at: $vagrant_box_cache_path"
    fi
  else
    echo "Using cached CentOS Vagrant box at $vagrant_box_cache_path"
  fi
}

cache_centos_iso()
{
  # Download a fresh CentOS ISO for Packer if it's not cached locally
  if [ ! -f  $centos_iso_cache_path ]; then
    echo "No cached CentOS ISO found, downloading..."
    curl -o $centos_iso_cache_path $centos_iso_url
  else
    echo "Using cached CentOS ISO at $centos_iso_cache_path"
  fi
}

if [ $mode == "basic" ]; then
  cache_odl_tb
  cache_vagrant_box
  cache_centos_iso
fi
