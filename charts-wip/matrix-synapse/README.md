Matrix Synapse
==============

[Synapse](https://github.com/matrix-org/synapse) is the current reference implementation of the [Matrix protocol](https://matrix.org).

## Prerequisites

- Kubernetes 1.15+
- Helm 3.0+
- Ingress installed in the cluster

**NB**; Matrix requires the use of valid certificates.

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

    helm install matrix-synapse --set config.serverName=chosenin.space --set wellknown.enabled=true

This would set up Synapse with client-server and federation both exposed on `chosenin.space/_matrix`, as well as a tiny lighttpd server that responds to federation lookups on `chosenin.space/.well-known/matrix/server`.

You can also use this to run a Synapse on a subdomain, with said subdomain as part of your MXIDs; (`@user:matrix.chosenin.space` in this case)

    helm install matrix-synapse --set config.serverName=matrix.chosenin.space --set wellknown.enabled=true

### On separate subdomain

If - on the other hand - you own the domain `example.com`, want your MXIDs in the form `@user:example.com`, but still want to run your Synapse on `matrix.example.com`. Then you have two options, using either DNS or well-known;

For DNS, you could install the chart as;

    helm install matrix-synapse --set config.serverName=example.com --set config.publicBaseUrl=https://matrix.example.com --set ingress.includeServerName=false --set ingress.hosts={example.com} --set ingress.csHosts={matrix.example.com} 

This will add only federation endpoints to `example.com`, along with client endpoints on `matrix.example.com`. You will also need to have valid certs for both `example.com` as well as `matrix.example.com` for your Synapse to use.
To get federation working with such a setup, you would need to add an SRV record to your DNS - for example;  
`_matrix._tcp.example.com 10 1 443 matrix.example.com`

If you want to use a well-known file for federation instead, then your install might look more like;

    helm install matrix-synapse --set config.serverName=example.com --set config.publicBaseUrl=https://matrix.example.com --set wellknown.enabled=true --set wellknown.host=matrix.example.com --set ingress.includeServerName=false --set ingress.hosts={matrix.example.com} --set ingress.csHosts={matrix.example.com} --set ingress.wkHosts={example.com}

With well-known federation, your client-to-server/public host is the one that needs to handle both client and federation traffic. On your main domain you'll instead only need something that can respond with a JSON file on the URL `example.com/.well-known/matrix/server`, which the included wellknown server will do.  
When using well-known federation, your Synapse cert would only need to be valid for `matrix.example.com`.


