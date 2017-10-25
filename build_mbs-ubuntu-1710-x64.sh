#! /bin/bash
set -e

CONTAINER=mbs-ubuntu-1710-x64-tmp
IMAGE=mbs-ubuntu-1710-x64

# Stop and delete any old container.
lxc stop ${CONTAINER} || echo "No running container found..."
lxc delete ${CONTAINER} || echo "No existing container..."
# Delete any old image.
lxc image delete ${IMAGE} || echo "No existing image..."

# Start a fresh container from the official image.
lxc launch ubuntu:17.10 ${CONTAINER}

# Wait until the network is up and running.
WAIT_CNT=0
WAIT_MAX=30
echo "Waiting for the network to come up (maximum ${WAIT_MAX} seconds)"
while [ ${WAIT_CNT} -lt ${WAIT_MAX} ]; do
	NETWORK_STATUS=`lxc exec ${CONTAINER} -- systemctl show --property=ActiveState systemd-resolved-update-resolvconf.path`
	if [ "${NETWORK_STATUS}" = "ActiveState=active" ]; then
		echo "OK, the network is up."
		break
	else
		sleep 1
		let WAIT_CNT=WAIT_CNT+1
		echo "${WAIT_CNT}"
	fi
done
if [ ${WAIT_CNT} -ge ${WAIT_MAX} ]; then
	echo "The network did not come up!"
	lxc stop ${CONTAINER}
	lxc delete ${CONTAINER}
	exit -1
fi

# Install the common packages.
lxc exec ${CONTAINER} -- apt-get update
lxc exec ${CONTAINER} -- apt-get install --assume-yes curl gcc g++ git lib32z1 make python2.7

# Add the repository for the build tools and install the key.
lxc exec ${CONTAINER} -- bash -c 'echo "deb http://download.opensuse.org/repositories/home:/doc_bacardi/xUbuntu_17.10/ /" > /etc/apt/sources.list.d/build_opensuse_org_home_docbacardi.list'
lxc exec ${CONTAINER} -- bash -c 'curl --location --silent http://download.opensuse.org/repositories/home:doc_bacardi/xUbuntu_17.10/Release.key | apt-key add -'
lxc exec ${CONTAINER} -- apt-get update

# Install the build tools from the new repository.
lxc exec ${CONTAINER} -- apt-get install --assume-yes cmake3 mingw-w64-mbs swig3

# Create a working folder.
lxc exec ${CONTAINER} -- mkdir /tmp/work

# Stop the running container. This is necessary before the "publish" step.
lxc stop ${CONTAINER}

# Turn the container into a new image.
echo "Publishing the new image..."
lxc publish ${CONTAINER} --alias=${IMAGE} description="This image contains the build environment for the MBS system on Ubuntu 17.10 64 bit."

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
