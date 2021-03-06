#! /bin/bash
set -e

CONTAINER=mbs-ubuntu-1704-x86-tmp
IMAGE=mbs-ubuntu-1704-x86

# Stop and delete any old container.
lxc stop ${CONTAINER} || echo "No running container found..."
lxc delete ${CONTAINER} || echo "No existing container..."
# Delete any old image.
lxc image delete ${IMAGE} || echo "No existing image..."

# Start a fresh container from the official image.
lxc launch ubuntu:17.04/i386 ${CONTAINER}
# FIXME: This waits until the network is up and running. It would be much better to poll on something.
# Maybe the output of "lxc list ..." is a good candidate.
sleep 5

# Remove the strange resolve entry.
lxc exec ${CONTAINER} -- bash -c 'sed --expression="s/hosts:          files resolve \[\!UNAVAIL=return\] dns/hosts:          files dns [NOTFOUND=return]/" --in-place /etc/nsswitch.conf'

# Install the common packages.
lxc exec ${CONTAINER} -- apt-get update
lxc exec ${CONTAINER} -- apt-get install --assume-yes curl gcc g++ git make python2.7

# Add the repository for the build tools and install the key.
lxc exec ${CONTAINER} -- bash -c 'echo "deb http://download.opensuse.org/repositories/home:/doc_bacardi/xUbuntu_17.04/ /" > /etc/apt/sources.list.d/build_opensuse_org_home_docbacardi.list'
lxc exec ${CONTAINER} -- bash -c 'curl --location --silent http://download.opensuse.org/repositories/home:doc_bacardi/xUbuntu_17.04/Release.key | apt-key add -'
lxc exec ${CONTAINER} -- apt-get update

# Install the build tools from the new repository.
lxc exec ${CONTAINER} -- apt-get install --assume-yes cmake3 mingw-w64-mbs swig3

# Create a working folder.
lxc exec ${CONTAINER} -- mkdir /tmp/work

# Stop the running container. This is necessary before the "publish" step.
lxc stop ${CONTAINER}

# Turn the container into a new image.
echo "Publishing the new image..."
lxc publish ${CONTAINER} --alias=${IMAGE} description="This image contains the build environment for the MBS system on Ubuntu 17.04 32 bit."

# Remove the temporary container.
lxc delete ${CONTAINER}

echo ""
echo " #######  ##    ## "
echo "##     ## ##   ##  "
echo "##     ## ##  ##   "
echo "##     ## #####    "
echo "##     ## ##  ##   "
echo "##     ## ##   ##  "
echo " #######  ##    ## "
echo ""
