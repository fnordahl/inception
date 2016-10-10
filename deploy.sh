#!/bin/bash -x

# XXX: Change this to the UUID of the network
#      the juju-created machines will run in.
NETWORK="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Perform Juju!
juju deploy bundle.yaml

# Wait for Juju-status to settle a bit
echo "Wait for Juju-status to settle a bit..."
sleep 10

# Get number of machines with ceph-osds
N_OSDS=`juju show-status ceph-osd|egrep "^[[:digit:]]+"|wc -l`
N_OSDS_STARTED=0

# Wait for machines to get started
echo "Waiting for machines hosting ceph-osd to be started before attaching volume..."
until [ ${N_OSDS_STARTED} -ge ${N_OSDS} ]; do
  N_OSDS_STARTED=`juju show-status ceph-osd|egrep "^[[:digit:]]+.*[a-z0-9-]{36}"|wc -l`
  sleep 2
done
for UUID in `juju show-status ceph-osd|egrep "^[[:digit:]]+.*"|egrep -o "[a-z0-9-]{36}"`; do
  # XXX: OpenStack (TM) Client should be able to use volume name
  #      but it does not actually work. Get UUID of Volume.
  VOLID=`openstack volume create --size 100 ceph-osd-${UUID}|grep " id "|egrep -o "[a-z0-9-]{36}"`
  sleep 1 # wait for completion
  # XXX: check server flavor and skip if it allready has ephemeral storage
  openstack server add volume --device /dev/vdb ${UUID} ${VOLID}
done

# Get number of machines with neutron-gateway
N_NGW=`juju show-status neutron-gateway|egrep "^[[:digit:]]+"|wc -l`
N_NGW_STARTED=0

# Wait for machines to get started
echo "Waiting for machines hosting neutron-gateway to be started before attaching ext NIC..."
until [ ${N_NGW_STARTED} -ge ${N_NGW} ]; do
  N_NGW_STARTED=`juju show-status neutron-gateway|egrep "^[[:digit:]]+.*[a-z0-9-]{36}"|wc -l`
  sleep 10
done
for UUID in `juju show-status neutron-gateway|egrep "^[[:digit:]]+.*"|egrep -o "[a-z0-9-]{36}"`; do
  PORT=`neutron port-create --name ext-${UUID} ${NETWORK}|grep " id "|egrep -o "[a-z0-9-]{36}"`
  nova interface-attach --port ${PORT} ${UUID}
done
