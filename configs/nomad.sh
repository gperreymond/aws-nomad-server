#!/bin/bash

echo "[INFO] prepare node"
mkdir -p /home/ssm-user/nomad/certs
mkdir -p /home/ssm-user/nomad/envs
mkdir -p /home/ssm-user/nomad/configs
sudo apt update

echo "[INFO] install jq"
sudo apt install -y jq

TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
TAGS=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID")
NAME_TAG=$(echo "$TAGS" | jq -r '.Tags[] | select(.Key=="Name") | .Value')
echo "[INFO] instance_id=$INSTANCE_ID / name=$NAME_TAG"

echo "[INFO] get all nomad certs"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-certs" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".$key")
  echo "$value" > "/home/ssm-user/nomad/certs/$key"
done

echo "[INFO] get all nomad configs"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-configs" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".$key")
  echo "$value" > "/home/ssm-user/nomad/configs/$key"
done

echo "[INFO] get all nomad envs"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-envs" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".$key")
  echo "$value" > "/home/ssm-user/nomad/envs/$key"
done

CNI_PLUGINS_VERSION="$(cat /home/ssm-user/nomad/envs/CNI_PLUGINS_VERSION)"
NOMAD_VERSION="$(cat /home/ssm-user/nomad/envs/NOMAD_VERSION)"

echo "[INFO] install hashi-up"
curl -sLS https://get.hashi-up.dev | sh
sudo cp hashi-up /usr/local/bin/hashi-up
hashi-up version

echo "[INFO] start initialization cni plugin"
curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/cni-plugins-linux-amd64-v${CNI_PLUGINS_VERSION}.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
sudo rm cni-plugins.tgz

echo "[INFO] install nomad"
hashi-up nomad install --local --version $NOMAD_VERSION --config-file /home/ssm-user/nomad/configs/nomad_config_hcl
nomad version
sudo service nomad restart