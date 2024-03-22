#!/bin/bash

echo "[INFO] prepare device"
DEVICE="/dev/nvme1n1"
PARTITIONED=$(lsblk "$DEVICE" | grep "part" | wc -l)
if [ "$PARTITIONED" = "1" ]; then
    echo "[WARN] devide already partitioned!"
else
  fdisk /dev/nvme1n1 <<EOF
n
p
1


w
EOF
  sleep 5
  mkfs.ext4 "${DEVICE}p1"
fi
mkdir /mnt/nomad
mount "${DEVICE}p1" /mnt/nomad
chown -R $USER:$USER /mnt/nomad

echo "[INFO] prepare node"
mkdir -p /home/ssm-user/nomad/certs
mkdir -p /home/ssm-user/nomad/envs
mkdir -p /home/ssm-user/nomad/configs
mkdir -p /home/ssm-user/nomad/etcd
sudo apt update

echo "[INFO] install tools"
sudo apt install -y jq net-tools iputils-ping

TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
TAGS=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID")
NAME_TAG=$(echo "$TAGS" | jq -r '.Tags[] | select(.Key=="Name") | .Value')
echo "[INFO] instance_id=$INSTANCE_ID / name=$NAME_TAG"

echo "[INFO] get all nomad certs"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-certs" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".\"$key\"")
  echo "$value" > "/home/ssm-user/nomad/certs/$key"
done

echo "[INFO] get all nomad configs"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-configs" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".\"$key\"")
  echo "$value" > "/home/ssm-user/nomad/configs/$key"
done

echo "[INFO] get all nomad etcd"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-etcd" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".\"$key\"")
  echo "$value" > "/home/ssm-user/nomad/etcd/$key"
done

echo "[INFO] get all nomad envs"
json_string=$(aws secretsmanager get-secret-value --secret-id "$NAME_TAG-envs" | jq -r '.SecretString')
keys=$(echo "$json_string" | jq -r 'keys[]')
for key in $keys; do
  value=$(echo "$json_string" | jq -r ".\"$key\"")
  echo "$value" > "/home/ssm-user/nomad/envs/$key"
done

CNI_PLUGINS_VERSION="$(cat /home/ssm-user/nomad/envs/CNI_PLUGINS_VERSION)"
NOMAD_VERSION="$(cat /home/ssm-user/nomad/envs/NOMAD_VERSION)"
NOMAD_REGION="$(cat /home/ssm-user/nomad/envs/NOMAD_REGION)"
NOMAD_DATACENTER="$(cat /home/ssm-user/nomad/envs/NOMAD_DATACENTER)"

echo "[INFO] prepare etcd meta"
ETCD_NODE_NAME="$(cat /home/ssm-user/nomad/etcd/$INSTANCE_ID | jq -r '.NODE_NAME')"
ETCD_NODE_IP="$(cat /home/ssm-user/nomad/etcd/$INSTANCE_ID | jq -r '.NODE_IP')"
ETCD_INITIAL_CLUSTER="$(cat /home/ssm-user/nomad/etcd/$INSTANCE_ID | jq -r '.INITIAL_CLUSTER')"
ETCD_CLUSTER_ENDPOINTS="$(cat /home/ssm-user/nomad/etcd/$INSTANCE_ID | jq -r '.CLUSTER_ENDPOINTS')"
if [ -z "$ETCD_NODE_NAME" ]; then
    echo "[ERROR] ETCD_NODE_NAME is mandatory!"
    exit 1
fi
if [ -z "$ETCD_NODE_IP" ]; then
    echo "[ERROR] ETCD_NODE_IP is mandatory!"
    exit 1
fi
if [ -z "$ETCD_INITIAL_CLUSTER" ]; then
    echo "[ERROR] ETCD_INITIAL_CLUSTER is mandatory!"
    exit 1
fi
ETCD_NODE_NAME_ESCAPED=$(sed 's/[\/&]/\\&/g' <<< "$ETCD_NODE_NAME")
ETCD_NODE_IP_ESCAPED=$(sed 's/[\/&]/\\&/g' <<< "$ETCD_NODE_IP")
ETCD_INITIAL_CLUSTER_ESCAPED=$(sed 's/[\/&]/\\&/g' <<< "$ETCD_INITIAL_CLUSTER")
ETCD_CLUSTER_ENDPOINTS_ESCAPED=$(sed 's/[\/&]/\\&/g' <<< "$ETCD_CLUSTER_ENDPOINTS")

sed -i "s|ETCD_NODE_NAME|$ETCD_NODE_NAME_ESCAPED|g" /home/ssm-user/nomad/configs/nomad_config_hcl
sed -i "s|ETCD_NODE_IP|$ETCD_NODE_IP_ESCAPED|g" /home/ssm-user/nomad/configs/nomad_config_hcl
sed -i "s|ETCD_INITIAL_CLUSTER|$ETCD_INITIAL_CLUSTER_ESCAPED|g" /home/ssm-user/nomad/configs/nomad_config_hcl
sed -i "s|ETCD_CLUSTER_ENDPOINTS|$ETCD_CLUSTER_ENDPOINTS_ESCAPED|g" /home/ssm-user/nomad/configs/nomad_config_hcl

echo ""
echo "============================================================="
echo "[INFO] CNI_PLUGINS_VERSION............ $CNI_PLUGINS_VERSION"
echo "[INFO] NOMAD_VERSION.................. $NOMAD_VERSION"
echo "[INFO] NOMAD_REGION................... $NOMAD_REGION"
echo "[INFO] NOMAD_DATACENTER............... $NOMAD_DATACENTER"
echo "============================================================="
echo ""

echo "[INFO] start initialization docker"
sudo apt-get install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
VPC resources on ${var.cluster_name}
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

