# Create MariaDB

This service uses the Hetzner cloud api to create a set of servers and a floating ip address, then provisions them to use
pacemaker to cluster them.

Cluster Services:
- cloud api fencing(stonith) devices
- DRBD active/passive file sharing
- cloud api floating ip management - attached to drbd master
- Ip Addresses is added and removed from the host network device, following the
  floating ip
- MariaDB is started on the drbd active host
- MariaDB Backup is started on the host running mariadb

Finally the floating Ip is added to the current environment as external.

## MariDB Version

## Use case: Highly available MySQL Server
While it is certainly possible to run MySQL or MariaDB through docker we found
cutting out this level of abstraction greatly increased the level of server
stability.

## Persistence
For stable reruns of the image 3 informations need to be persistent:

- password of the cluster user
- public key allowing hosts to connect via the private key
- private key to connect to the hosts

### Volumes
This is the easy way but only possible if you have persistent storage available.  
Set `Volume Name` and `Volume Driver` to a persistent volume and the generated values will be stored there.

### Environment Variables
If you do not have access to persistent storage then generate the values yourself and set them while creating the service.
Use `local` as the `Volume Driver` when going with this approach.

- `ssh-keygen -t rsa -b 4096 ./id_rsa ''`
  - id\_rsa contains the `Private SSH Key`
  - id\_rsa.pub containts the `Public SSH Key`
- `tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1` will output a strong password for `Cluster User Password`

You can also simply choose a password for the cluster user.
