#!/bin/bash

echo "[INFO] prepare node"
mkdir -p /home/ssm-user/nomad/certs
mkdir -p /home/ssm-user/nomad/secrets
mkdir -p /home/ssm-user/nomad/configs
sudo apt update

echo "[INFO] install jq"
sudo apt install -y jq
