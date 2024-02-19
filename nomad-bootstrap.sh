#!/bin/bash

set -e

# -----------------------
# PREPARE
# -----------------------

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -stage) stage="$2"; shift ;;
        *) echo "[ERROR] param is not authorized"; exit 1;;
    esac
    shift
done

if [[ -z "$stage" ]]; then
    echo "[ERROR] stage is mandatory"
    exit 1
fi

outputs=$(terragrunt output -json --terragrunt-config "${stage}")
aws_region=$(echo $outputs | jq -r '.aws_region.value')
nomad_region=$(echo $outputs | jq -r '.nomad_region.value')
nomad_datacenter=$(echo $outputs | jq -r '.nomad_datacenter.value')
nomad_address=$(echo $outputs | jq -r '.nomad_address.value')

aws_secret_name="nomad-server-$nomad_region-$nomad_datacenter-bootstrap"

# -----------------------
# RESUME
# -----------------------

echo ""
echo "============================================================="
echo "[INFO] aws_region.................. $aws_region"
echo "[INFO] aws_secret_certs_name....... $aws_secret_certs_name"
echo "[INFO] aws_secret_name............. $aws_secret_name"
echo "[INFO] nomad_region................ $nomad_region"
echo "[INFO] nomad_datacenter............ $nomad_datacenter"
echo "[INFO] nomad_address............... $nomad_address"
echo "============================================================="
echo ""

# -----------------------
# EXECUTE COMMAND
# -----------------------

if aws secretsmanager describe-secret --region $aws_region --secret-id $aws_secret_name &> /dev/null; then
    echo "[WARN] the secret exists"
    echo ""
    exit 0
else
    echo "[INFO] the secret does not exist"
fi

echo "[INFO] nomad bootstrap acl"
curl -s -X POST $nomad_address/v1/acl/bootstrap > bootstrap.json

# -----------------------
# CREATE AWS SECRET
# -----------------------

content=$(cat bootstrap.json)
final_json="{}"
final_json=$(echo "$final_json" | jq --arg filename "bootstrap" --arg content "$content" '. + { ($filename): $content }')
aws secretsmanager delete-secret --region $aws_region --secret-id $aws_secret_name --force-delete-without-recovery
while ! aws secretsmanager create-secret --region $aws_region --name $aws_secret_name --secret-string "$final_json" &> /dev/null; do
    echo "[INFO] waiting for the secret to be created..."
    sleep 1
done
echo "[INFO] the secret has been create"
rm bootstrap.json

# -----------------------
# END
# -----------------------

echo ""
