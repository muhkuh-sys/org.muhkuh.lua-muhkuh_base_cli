#! /bin/bash
set -e

# This is the name of the working container.
# FIXME: generate something unique to avoid collisions if more than one build is running.
CONTAINER=c0

# Get the project directory.
PRJDIR=`pwd`

# Make sure that the "targets" folder exists.
# NOTE: do not remove it, maybe there are already components.
mkdir -p ${PRJDIR}/targets

# Start the container and mount the project folder.
lxc init mbs-ubuntu-1604-x64 ${CONTAINER}
lxc config device add ${CONTAINER} projectDir disk source=${PRJDIR} path=/tmp/work
lxc start ${CONTAINER}
sleep 5

# Prepare the build folder.
lxc exec ${CONTAINER} -- bash -c 'rm -rf /tmp/build'
lxc exec ${CONTAINER} -- bash -c 'mkdir /tmp/build'
lxc exec ${CONTAINER} -- bash -c 'mount --bind /tmp/build /tmp/work/targets'

# Build the artifact.
lxc exec ${CONTAINER} -- bash -c 'cd /tmp/work && python2.7 mbs/mbs'

# Get the artifacts.
FILELIST=`lxc exec ${CONTAINER} -- bash -c 'find "/tmp/work" -path "/tmp/work/targets/jonchki/repository/org/muhkuh/tools/muhkuh_base_cli/*" -type f'`
echo ${FILELIST}
for strAbsolutePath in ${FILELIST}; do
	echo "Pull ${strAbsolutePath}"
	lxc file pull ${CONTAINER}${strAbsolutePath} targets/
done

# Stop and remove the container.
lxc stop ${CONTAINER}
lxc delete ${CONTAINER}
