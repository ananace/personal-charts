Matrix Media Repo
=================

[MMR](https://github.com/t2bot/matrix-media-repo) is a highly configurable multi-homeserver media repository for Matrix.

Upstream docs are available at https://docs.t2bot.io/matrix-media-repo/

## Installing

To fully support Matrix protocol version 1.11 and forwards, you'll need to follow the [MMR documentation on signing keys](https://docs.t2bot.io/matrix-media-repo/v1.3.5/installation/signing-key/).  
Of note is that the merged signing key will have to be stored into the Synapse Secret, and Synapse will have to be restarted to pick up the merged key.
