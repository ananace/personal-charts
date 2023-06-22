Lemmy
=====

[Lemmy](https://join-lemmy.org) is an ActivityPub-powered link aggregator for the federated web, provided by default with a UI that's similar to services like Digg/HackerNews/Reddit/etc

## Installing

A minimal Lemmy install could look something like;

    helm install lemmy ananace-charts/lemmy --set serverName=lemmy.example.com

This will set up a full Lemmy install, with backend, frontend (using lemmy-ui), nginx-based routing proxy, pict-rs media storage, and postgresql server.  
Note that this will require a working ingress in your cluster, if an ingress isn't available you can also deploy the proxy as a `LoadBalancer`/`NodePort` service in order to try the system out.

**Nota Bene**: The system **will** require valid TLS certificates and working routing on regular HTTP(s) ports in order for federation to work.

The initial postgres migration also currently fails unless the Lemmy user in Postgres is a superuser.

S3 storage is also supported for media, refer to the [values](values.yaml) under `.pictrs.storage` for the necessary configuration.
