#!/bin/bash

set -e

mkdir -p /etc/gitlab/

/usr/bin/aws secretsmanager get-secret-value --secret-id ${SECRET_NAME} | jq --raw-output '.SecretString' > ./secrets.json
cat secrets.json | jq --raw-output '."ssh_host_ecdsa_key"' | base64 --decode > /etc/gitlab/ssh_host_ecdsa_key
cat secrets.json | jq --raw-output '."ssh_host_ecdsa_key.pub"' | base64 --decode > /etc/gitlab/ssh_host_ecdsa_key.pub
cat secrets.json | jq --raw-output '."ssh_host_ed25519_key"' | base64 --decode > /etc/gitlab/ssh_host_ed25519_key
cat secrets.json | jq --raw-output '."ssh_host_ed25519_key.pub"' | base64 --decode > /etc/gitlab/ssh_host_ed25519_key.pub
cat secrets.json | jq --raw-output '."ssh_host_rsa_key"' | base64 --decode > /etc/gitlab/ssh_host_rsa_key
cat secrets.json | jq --raw-output '."ssh_host_rsa_key.pub"' | base64 --decode > /etc/gitlab/ssh_host_rsa_key.pub
cat secrets.json | jq --raw-output '."gitlab-secrets.json"' > /etc/gitlab/gitlab-secrets.json
rm ./secrets.json

chmod 600 /etc/gitlab/*_key
chmod 600 /etc/gitlab/gitlab-secrets.json

# Tweak git settings to support checking out large repos without corruption
cat << EOF > /etc/gitlab/post-reconfigure.sh
echo "Applying custom git config for Data Workspace ..."

git config --system pack.windowMemory "100m"
git config --system pack.SizeLimit "100m"
git config --system pack.threads "1"
git config --system pack.window "0"

echo "Done applying custom git config for Data Workspace"
EOF

chmod +x /etc/gitlab/post-reconfigure.sh

export GITLAB_POST_RECONFIGURE_SCRIPT=/etc/gitlab/post-reconfigure.sh

/assets/init-container
