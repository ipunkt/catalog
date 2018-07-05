# Create Loadbalancer

This service uses the Hetzner cloud api to create a set of servers and a floating ip address, then provisions them to use
pacemaker to cluster them.

Cluster Services:
- cloud api fencing(stonith) devices
- cloud api floating ip management
- Ip Addresses are permanently added to the hosts network interfaces

## Use case: Loadbalancer
The intended use case for this image is for the created servers to be load balancers using traefik for http/* and rancher
haproxy tcp for other protocols.

For this use case start traefik and/or the rancher loadbalancer services with `always run one instance on every host` and
add a scheduling rule `must have a host label of lb = true`.  
Ajust the label name and value with the one you choose in the `Host Labels`

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
  - id_rsa contains the `Private SSH Key`
  - id_rsa.pub containts the `Public SSH Key`
- `tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1` will output a strong password for `Cluster User Password`

You can also simply choose a password for the cluster user.
  

## Important: Permanently added floating ips
Floating ip addresses are permanently added to the hosts network interfaces. This is necessary because containers can
only bind to the floating ip address when it is added to the interface.  
The drawback to this is that that requests to the floating ip address will always go to `localhost` for those hosts even
if the floating ip is currently owned by the other server.

The most immediate effect of this is that you should not use services on this host that connect to the fallback ip address
unless you know what you are doing.

Possible fail scenario:
- Host2 is not owning the floating ip address
- It runs traefik with letsencrypt http challenge mode
- A service 'api query service' on Host2 connects to a domain on the fallback ip
- Traefik on Host2 answers and needs to create the tls certificate through letsencrypt
- Traefik on Host2 sends a http challenge to letsencrypt using the domain on the fallback ip address
- Letsencrypt connects to the domain, ending up on Host1 as the current owner of the fallback ip
- Traefik on Host1 does not answer the challenge as it does not know about it
- The Letsencrypt challenge fails.
