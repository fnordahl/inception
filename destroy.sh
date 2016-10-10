#!/bin/bash -x

# Get number of machines with ceph-osds
N_OSDS=`juju show-status ceph-osd|egrep "^[[:digit:]]+"|wc -l`

# Gather resource UUIDS
VOLUME_UUIDS=`juju show-status ceph-osd|egrep "^[[:digit:]]+.*"|egrep -o "[a-z0-9-]{36}"`
PORT_UUIDS=`juju show-status neutron-gateway|egrep "^[[:digit:]]+.*"|egrep -o "[a-z0-9-]{36}"`

# Destroy machines
for MACHINE in `juju status|egrep -o "^[[:digit:]]+"`; do
  juju remove-machine --force ${MACHINE}
done

# Remove applications
for APPLICATION in ceph-mon ceph-osd ceph-radosgw cinder \
    cinder-ceph glance keystone mysql neutron-api \
    neutron-gateway neutron-openvswitch \
    nova-cloud-controller nova-compute ntp \
    openstack-dashboard rabbitmq-server;
do
  juju remove-application ${APPLICATION}
done

if [ ${N_OSDS} -gt 0 ]; then
  # Build search string for egrep
  UUID_SEARCH_STR=""
  for UUID in ${VOLUME_UUIDS}; do
    if [ -z ${UUID_SEARCH_STR} ]; then
      UUID_SEARCH_STR="(${UUID}"
    else
      UUID_SEARCH_STR="${UUID_SEARCH_STR}|${UUID}"
    fi
  done
  UUID_SEARCH_STR="${UUID_SEARCH_STR})"

  # Wait for machines to be deleted
  echo "Waiting for machines hosting ceph-osd to be deleted before detaching volume..."
  N_OSDS_RUNNING=1
  until [ ${N_OSDS_RUNNING} -eq 0 ]; do
    N_OSDS_RUNNING=`juju show-status |egrep "${UUID_SEARCH_STR}"|wc -l`
    sleep 2
  done
fi

# Clean up resources
echo "Clean up resources..."
for UUID in ${VOLUME_UUIDS}; do
  openstack volume delete ceph-osd-${UUID}
done
for UUID in ${PORT_UUIDS}; do
  openstack port delete ext-${UUID}
done
