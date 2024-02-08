Puppetboard
===========

[Puppetboard](https://github.com/voxpupuli/puppetboard) is a web frontend for PuppetDB, the discovery/storage backend for Puppet.

## Installing

Puppetboard requires a valid Puppet certificate in order to connect to PuppetDB. One can be generated on your Puppet master by running the following command;

    puppetserver ca generate --certname puppetboard.example.com

This will create the necessary key and cert under `/etc/puppetlabs/puppet/ssl/{certs,private_keys}/puppetboard.example.com.pem`, you will need to either provide these in a secret, volume, or as Chart install values in order to set up a working Puppetboard install.

E.g.

```console
$ kubectl create secret generic puppetboard-keys \
    --from-file=PUPPETDB_KEY=/etc/puppetlabs/puppet/ssl/private_keys/puppetboard.example.com.pem \
    --from-file PUPPETDB_CERT=/etc/puppetlabs/puppet/ssl/certs/puppetboard.example.com.pem
$ helm install puppetboard ananace-charts/puppetboard --set puppetdb.ssl.key.existingSecret=puppetboard-keys,puppetdb.ssl.cert.existingSecret=puppetboard-keys
```

For more information about configuring Puppetboard, refer to their [readme](https://github.com/voxpupuli/puppetboard?tab=readme-ov-file#configuration).
