Inception
=========

Deploy OpenStack in a OpenStack cloud using Juju 2.0

- Bundle is based on https://jujucharms.com/openstack-base/
- Altered to deploy services to instances instead of the default of creating
  LXD containers
  - TODO: It is probably possible to make the upstream bundle work AS-IS. Have
          to figure out plumbing for the LXD networking
- Scripts used to manage life cycle of Cinder Volumes for ceph-osd units and
  Neutron ports for neutron-gateway units
  - TODO: It is probably possible to manage this with Juju itself. Figure out
          how.

Prerequisites
-------------
- Running OpenStack cloud
- DNS setup to resolve/access new instances by name
  - Either Designate set up to integrate with Nova and Neutron
  - serverstack-dns
    - https://launchpad.net/~openstack-charmers/+archive/ubuntu/test-tools

Instructions
------------
1. Launch Ubuntu Xenial instance, load OpenStack credentials
2. Add Juju devel PPA
 
    ```
    sudo add-apt-repository ppa:juju/devel
    sudo apt-get update
    sudo apt-get install juju
    ```

3. Add cloud to Juju

    ```
    juju add-cloud mycloud mycloud.yaml
    ```

4. Bootstrap Juju

    ```
    juju bootstrap mycloud myregion --config config.yaml
    ```

5. Check status and tail log

    ```
    juju status
    juju debug-log
    ```

6. Add UUID of your projects network to deploy.sh
7. Run it

    ```
    ./deploy.sh
    ```

8. Get coffee, tea, (popcorn?) or whatever you favor to do while waiting for
   computers
42. profit!
51. ./destroy.sh
