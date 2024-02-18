#!/bin/bash

set -e

rm -rf *.pem

# -----------------------
# PREPARE
# -----------------------

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -aws_region) aws_region="$2"; shift ;;
        -region) region="$2"; shift ;;
        -datacenter) datacenter="$2"; shift ;;
        *) echo "[ERROR] param is not authorized"; exit 1;;
    esac
    shift
done

if [[ -z "$aws_region" ]]; then
    echo "[ERROR] aws_region is mandatory"
    exit 1
fi

if [[ -z "$region" ]]; then
    echo "[ERROR] region is mandatory"
    exit 1
fi

if [[ -z "$datacenter" ]]; then
    echo "[ERROR] datacenter is mandatory"
    exit 1
fi

aws_secret_name="nomad-server-$datacenter-certs"

# -----------------------
# RESUME
# -----------------------

echo ""
echo "==========================================================================="
echo "[INFO] aws_region........................... '${aws_region}'"
echo "[INFO] region............................... '${region}'"
echo "[INFO] datacenter............................'${datacenter}'"
echo "[INFO] aws_secret_name...................... '${aws_secret_name}'"
echo "==========================================================================="
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

nomad tls ca create
nomad tls cert create -server -region $region
nomad tls cert create -client -region $region
nomad tls cert create -cli -region $region

# -----------------------
# CREATE AWS SECRET
# -----------------------

final_json="{}"
for file in *.pem; do
    [ -f "$file" ] || continue
    filename=$(basename "$file" .pem)
    filename=$(echo $filename | sed "s/$region-//g")
    filename=$(echo $filename | sed "s/-/_/g")
    content=$(cat "$file")
    final_json=$(echo "$final_json" | jq --arg filename "$filename" --arg content "$content" '. + { ($filename): $content }')
done

aws secretsmanager delete-secret --region $aws_region --secret-id $aws_secret_name --force-delete-without-recovery
while ! aws secretsmanager create-secret --region $aws_region --name $aws_secret_name --secret-string "$final_json" &> /dev/null; do
    echo "[INFO] waiting for the secret to be created..."
    sleep 1
done
echo "[INFO] the secret has been create"

# -----------------------
# END
# -----------------------

echo ""

