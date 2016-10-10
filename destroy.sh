#!/bin/bash -x

# Gather resource UUIDS
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

# Clean up resources
echo "Clean up resources..."
for UUID in ${PORT_UUIDS}; do
  openstack port delete ext-${UUID}
done
