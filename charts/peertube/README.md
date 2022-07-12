Peertube
========

[Peertube](https://joinpeertube.org/) is a federated video hosting platform for the open web.

## Prerequisites

- Non-EoL Kubernetes cluster
- Helm 3
- SMTP server available

## Installing

Peertube will require three pieces of data to be installed; A server name, an admin contact email address, and an SMTP server configuration.

For a simple install with an authentication-less SMPT server this could look like;

    helm install peertube ananace-charts/peertube --set config.serverName=videos.example.com,config.admin.email=admin@example.com,config.mail.hostname=smtp.example.com

### Live-streaming / RTMP

For the live-streaming functionality to work, you will need to make sure your ingress forwards TCP connections on the RTMP port. (1935 by default)

With that in place, you can enable live-streaming support either with `extraConfig.live.enabled=true` or by having `config.webadminConfig=true` and activating it from inside the system itself.
