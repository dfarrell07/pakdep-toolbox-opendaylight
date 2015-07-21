#/usr/bin/env bash
# Locally cache large packaging and deployment artifacts

# Echo commands as they are run
set -x

install_extras=true

# NB: These will need to be updated for version bumps
odl_version="0.3.0-Lithium"

# Common names used in this script
odl_tarball="distribution-karaf-$odl_version.tar.gz"
centos_iso="CentOS-7-x86_64-Minimal-1503-01.iso"
centos_vagrant_box="chef-centos-7.0-virtualbox-1.0.0.box"
odl_vagrant_box="opendaylight-2.3.0-centos-1503.box"

# Common paths used in this script
# TODO: Smarter cache paths
odl_tb_url="https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/$odl_version/$odl_tarball"
odl_tb_cache_path="$odl_tarball"
centos_iso_cache_path="$centos_iso"
centos_iso_url="http://mirrors.seas.harvard.edu/centos/7/isos/x86_64/$centos_iso"
centos_vagrant_box_cache_path="$centos_vagrant_box"
odl_vagrant_box_cache_path="$odl_vagrant_box"

artifact_cached()
{
  # Check if a given artifact is cached (file exists)
  cache_path=$1

  if [ -f  $cache_path ]; then
    echo "Cache populated: $cache_path"
    return 0
  else
    echo "Cache empty: $cache_path"
    return 1
  fi
}

assert_artifact_cached()
{
  # Exit with an error if the given artifact isn't cached
  cache_path=$1

  if ! artifact_cached $cache_path; then
    echo "Cache asserted populated but empty!"
    echo "Failing cache: $cache_path"
    exit 1
  fi
}

dl_artifact()
{
  # Download artifact if it's not cached locally
  url=$1
  cache_path=$2

  if ! artifact_cached $cache_path; then
    curl -o $cache_path $url
  fi

  assert_artifact_cached $cache_path
}

cache_odl_tb()
{
  dl_artifact $odl_tb_url $odl_tb_cache_path
}

cache_centos_iso()
{
  # Download a fresh CentOS ISO for Packer if it's not cached locally
  dl_artifact $centos_iso_url $centos_iso_cache_path
}

cache_centos_vagrant_box()
{
  # Download a CentOS Vagrant base box if it's not cached locally
  if ! artifact_cached $centos_vagrant_box_cache_path; then
    # Download a CentOS 7 Vagant base box if it's not cached by Vagrant
    vagrant box add --provider virtualbox chef/centos-7.0

    # Build a .box file from the unpacked local version added above. Vagrant
    #   doesn't have a way to pull .box files without unpacking them, so two steps.
    vagrant box repackage chef/centos-7.0 virtualbox 1.0.0
    mv package.box $centos_vagrant_box_cache_path

    # Confirm the CentOS Vagrant base box was output to expected location
    assert_artifact_cached $centos_vagrant_box_cache_path
  fi
}

cache_odl_vagrant_box()
{
  # TODO: Download OpenDaylight's Vagrant base box if it's not cached locally
  if ! artifact_cached $odl_vagrant_box_cache_path; then
    # Download a CentOS 7 Vagant base box if it's not cached by Vagrant
    vagrant box add --provider virtualbox dfarrell07/opendaylight

    # Build a .box file from the unpacked local version added above. Vagrant
    #   doesn't have a way to pull .box files without unpacking them, so two steps.
    vagrant box repackage dfarrell07/opendaylight virtualbox 2.3.0
    mv package.box $odl_vagrant_box_cache_path

    # Confirm the CentOS Vagrant base box was output to expected location
    assert_artifact_cached $odl_vagrant_box_cache_path
  fi
}

cache_odl_tb
cache_centos_iso
cache_centos_vagrant_box

if [ "$install_extras" == true ]; then
  cache_odl_vagrant_box
fi
