#!/bin/sh

set -eu

# Set deploy key
SSH_PATH="$HOME/.ssh"
mkdir -p "$SSH_PATH"
echo "$INPUT_DEPLOY_KEY" > "$SSH_PATH/deploy_key"
chmod 600 "$SSH_PATH/deploy_key"


# Host keys are verified against DNSSEC-signed SSHFP records. glibc clears the
# AD bit unless trust-ad is set, which makes ssh treat every SSHFP record as
# insecure and refuse the connection.
RES_OPTIONS="${RES_OPTIONS:+$RES_OPTIONS }trust-ad"
export RES_OPTIONS


# Optional known_hosts, for hosts that publish no SSHFP records
KNOWN_HOSTS="$SSH_PATH/known_hosts"
echo "${INPUT_KNOWN_HOSTS:-}" > "$KNOWN_HOSTS"
chmod 600 "$KNOWN_HOSTS"


SSH_OPTIONS="-i $SSH_PATH/deploy_key -o BatchMode=yes -o UserKnownHostsFile=$KNOWN_HOSTS -o VerifyHostKeyDNS=yes -o StrictHostKeyChecking=yes"


# Do deployment
sh -c "rsync $INPUT_FLAGS -e 'ssh $SSH_OPTIONS' $INPUT_EXCLUDES $GITHUB_WORKSPACE/$INPUT_LOCALPATH $INPUT_USER@$INPUT_HOST:$INPUT_REMOTEPATH"
