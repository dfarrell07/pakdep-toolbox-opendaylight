#/usr/bin/env bash
# Build a tarball with everything cached for consumption by a tutorial

# Echo commands as they are run
set -x

# Common names used in this script
pakdep_box="pakdep.box"

# Call cache script
./cache/cache.sh cache/

# Update the submodules
git submodule update --remote integration
git submodule update --remote puppet-opendaylight
git submodule update --remote ansible-opendaylight
git submodule update --remote vagrant-opendaylight

# Build pakdep
#vagrant up pakdep

# Export pakdep
if [ -f $pakdep_box ]; then
  echo "Packer fails to package when the output file exists. Removing it..."
  rm $pakdep_box
fi
vagrant package pakdep --output $pakdep_box
echo "May want to update your version of pakdep with something like:"
echo "vagrant box add --name "\<name for Vagrant to use\>" $pakdep_box --force"

# TODO: Make a tarball of everything

