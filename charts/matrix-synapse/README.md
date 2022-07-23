Matrix Synapse
==============

[Synapse](https://github.com/matrix-org/synapse) is the current reference implementation of the [Matrix protocol](https://matrix.org).

For questions/help on the chart, feel free to drop in at [#matrix-on-kubernetes:fiksel.info](https://matrix.to/#/#matrix-on-kubernetes:fiksel.info).  
This chart is hosted [on GitLab](https://gitlab.com/ananace/charts).

__Attention:__ _The upgrade to 1.51.0 requires manual action, please read the upgrade instructions [below](#upgrading)._

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- Ingress installed in the cluster

**NB**; Matrix requires the use of valid SSL certificates for federation.

## Installing

To run a federating Matrix server, you need to have a publicly accessible subdomain that Kubernetes has an ingress on.  
You will also require some federation guides, either in the form of a `.well-known/matrix/server` server or as an SRV record in DNS.

When using a well-known entry, you will need to have a valid cert for whatever subdomain you wish to serve Synapse on.
When using an SRV record, you will additionally need a valid cert for the main domain that you're using for your MXIDs.

## Installation Examples

Refer to [the main Synapse docs](https://github.com/matrix-org/synapse/blob/master/docs/federate.md) for more information.

### On main domain / with subdomain MXIDs

For the simplest possible Matrix install, you can run your Synapse install on the root of the domain you wish in your MXIDs.
If you - for instance - own the domain `chosenin.space` and want to run Matrix on it, you would simply install the chart as;

    helm install matrix-synapse ananace-charts/matrix-synapse --set serverName=chosenin.space --set wellknown.enabled=true

This would set up Synapse with client-server and federation both exposed on `chosenin.space/_matrix`, as well as a tiny lighttpd server that responds to federation lookups on `chosenin.space/.well-known/matrix/server`.

You can also use this to run a Synapse on a subdomain, with said subdomain as part of your MXIDs; (`@user:matrix.chosenin.space` in this case)

    helm install matrix-synapse ananace-charts/matrix-synapse --set serverName=matrix.chosenin.space --set wellknown.enabled=true

### On separate subdomain

If - on the other hand - you own the domain `example.com`, want your MXIDs in the form `@user:example.com`, but still want to run your Synapse on `matrix.example.com`. Then you have two options, using either DNS or well-known;

For DNS, you could install the chart as;

    helm install matrix-synapse ananace-charts/matrix-synapse --set serverName=example.com --set publicServerName=matrix.example.com

This will add federation endpoints to `example.com`, along with client endpoints on `matrix.example.com`. For this to work, you will need to have valid certs for both `example.com` as well as `matrix.example.com` for your Synapse to use.
To get federation working with such a setup, you would also need to add an SRV record to your DNS - for example;  

    _matrix._tcp.example.com 10 1 443 matrix.example.com

If you want to use a well-known file for federation instead of an SRV record, then your install might look more like;

    helm install matrix-synapse ananace-charts/matrix-synapse --set serverName=example.com --set publicServerName=matrix.example.com --set wellknown.enabled=true

With well-known federation, your client-to-server/public host is the one that needs to handle both client and federation traffic. On your main domain you'll instead only need something that can respond with a JSON file on the URL `example.com/.well-known/matrix/server` - which the included wellknown server will gladly do for you.  
Additionally, when using well-known federation, your Synapse cert only needs to be valid for `matrix.example.com`.

&nbsp;

More advanced setups can be made using `ingress.hosts`, `ingress.csHosts`, and `ingress.wkHosts` for server-server, client-server, and well-known endpoints respectively.  
Alternatively, you can use your own ingress setup, or switch the main service to `LoadBalancer` and add a TLS listener.

### Application services / extra config files

Synapse is configured to read all configuration files found under `/synapse/config/conf.d/` - which is mounted as an emptyDir to allow for read-only root.

You can mount your additional configuration values under here if you want to have configuration that doesn't map well to the `extraConfig`/`extraSecrets` values.
Note that due to how the mounts are set up, you will have to `subPath`-mount individual files into the folder in order for them to be loaded.

## Upgrading

### To v1.51.0
The redis subchart was upgraded in this release which changed immutable values of the StatefulSet. So, to perform this upgrade, perform the following steps. Make sure to adapt the names and arguments to your situation.

```
# Delete the old StatefulSet but leave the Pod alive
kubectl delete statefulset --cascade=orphan matrix-synapse-redis-master

# Upgrade the chart and create a new StatfulSet for redis
helm upgrade matrix-synapse matrix-synapse

# Delete the old Pod so the new StatefulSet can take over
kubectl delete pod matrix-synapse-redis-master-0   
```
