# rsync deployments

This GitHub Action deploys files in `GITHUB_WORKSPACE` to a folder on a server via rsync over ssh. 

This action would usually follow a build/test action which leaves deployable code in `GITHUB_WORKSPACE`.

# Required secrets

This action needs a `DEPLOY_KEY` secret variable. This should be the private key part of an ssh key pair. The public key part should be added to the authorized_keys file on the server that receives the deployment.

# Host key verification

Host keys are verified against DNSSEC-signed `SSHFP` records in DNS
(`VerifyHostKeyDNS=yes`, `StrictHostKeyChecking=yes`). Nothing is
trusted on first use.

Publish the records for your deployment target:

```
ssh-keygen -r myserver.com
```

Add the output to the zone, and make sure the zone is DNSSEC-signed. Verify
with:

```
ssh -o VerifyHostKeyDNS=yes -v deploybot@myserver.com true
```

`found N secure fingerprints in DNS` means it works. `insecure` means the
records are not covered by a validated DNSSEC signature, and the deployment
will fail.

Validation relies on the runner's resolver setting the AD bit; the action sets
`RES_OPTIONS=trust-ad` so glibc passes it through. If the resolver does not
validate DNSSEC, verification fails closed - the deployment aborts with
`Host key verification failed` rather than connecting unverified.

For hosts that publish no SSHFP records, pass the key explicitly via the
optional `KNOWN_HOSTS` input (see below) instead.

# Required inputs

This action requires six inputs:

1. `FLAGS` for any initial/required rsync flags, eg: `-avzr --delete`

2. `EXCLUDES` for any `--exclude` flags and directory pairs, eg: `--exclude .htaccess --exclude /uploads/`. Use `""` if none required.

3. `USER` for the server user, eg: `deploybot`

4. `HOST` for the deployment target, eg: `myserver.com`

5. `LOCALPATH` for the local path to sync, eg: `/dist/`

5. `REMOTEPATH` for the remote path to sync, eg: `/srv/myapp/public/htdocs/`

# Optional inputs

`KNOWN_HOSTS` for hosts without DNSSEC-signed `SSHFP` records. Contents are
used as the `known_hosts` file, eg the output of
`ssh-keyscan -t ed25519 myserver.com`. Check the key out of band before
trusting it.

# Example usage

```
name: Deploy to production

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: contention/rsync-deployments@v2.0.0
        with:
          FLAGS: -avzr --delete
          EXCLUDES: --exclude .htaccess --exclude /uploads/
          USER deploybot
          HOST: myserver.com
          LOCALPATH: /dist/
          REMOTEPATH: /srv/myapp/public/htdocs/
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
          # only needed if the host publishes no signed SSHFP records
          # KNOWN_HOSTS: ${{ secrets.KNOWN_HOSTS }}

```

## REMINDER! 

Check your keys. Check your deployment paths. Check your flags. And use at your own risk.
