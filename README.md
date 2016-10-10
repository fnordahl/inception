Inception
=========

Deploy OpenStack in a OpenStack cloud using Juju 2.0

Instructions
------------
1. Launch xenial instance, load openstack credentials
2. Add juju devel PPA
    
    sudo add-apt-repository ppa:juju/devel
    sudo apt-get update
    sudo apt-get install juju
    
3. juju add-cloud mycloud mycloud.yaml
4. juju bootstrap mycloud myregion --config config.yaml
5. juju status; juju debug-log (keep window)
6. Add UUID of your projects network to deploy.sh
7. ./deploy.sh
8. get coffee, tea, (popcorn?) or whatever you favor to do while waiting for computers
..
42. profit!
..
51. ./destroy.sh
