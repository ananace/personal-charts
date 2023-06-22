Lemmy
=====

[Lemmy](https://join-lemmy.org) is an ActivityPub-powered link aggregator for the federated web, provided by default with a UI that's similar to services like Digg/HackerNews/Reddit/etc

## Installing

A minimal Lemmy install could look something like;

    helm install lemmy ananace-charts/lemmy --set ingress.host=lemmy.example.com

Note that the system will require valid TLS certificates in order for federation to work as expected.

S3 storage is supported for media, refer to the [values](values.yaml) for `.pictrs.storage`.
