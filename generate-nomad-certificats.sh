#!/bin/bash

set -e

rm -rf *.pem

# -----------------------
# PREPARE
# -----------------------

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -aws_region) aws_region="$2"; shift ;;
        -datacenter) datacenter="$2"; shift ;;
        -tls_ca_command_line) tls_ca_command_line="$2"; shift ;;
        -tls_cert_server_command_line) tls_cert_server_command_line="$2"; shift ;;
        -tls_cert_client_command_line) tls_cert_client_command_line="$2"; shift ;;
        -tls_cert_cli_command_line) tls_cert_cli_command_line="$2"; shift ;;
        *) echo "[ERROR] param is not authorized"; exit 1;;
    esac
    shift
done

if [[ -z "$aws_region" ]]; then
    echo "[ERROR] aws_region is mandatory"
    exit 1
fi

if [[ -z "$datacenter" ]]; then
    echo "[ERROR] datacenter is mandatory"
    exit 1
fi

if [[ -z "$tls_ca_command_line" ]]; then
    echo "[ERROR] tls_ca_command_line is mandatory"
    exit 1
fi

if [[ -z "$tls_cert_server_command_line" ]]; then
    echo "[ERROR] tls_cert_server_command_line is mandatory"
    exit 1
fi

if [[ -z "$tls_cert_client_command_line" ]]; then
    echo "[ERROR] tls_cert_client_command_line is mandatory"
    exit 1
fi

if [[ -z "$tls_cert_cli_command_line" ]]; then
    echo "[ERROR] tls_cert_cli_command_line is mandatory"
    exit 1
fi

aws_secret_name="nomad-server-$datacenter-certs"

# -----------------------
# RESUME
# -----------------------

echo ""
echo "==========================================================================="
echo "[INFO] aws_region........................... '${aws_region}'"
echo "[INFO] datacenter............................'${datacenter}'"
echo "[INFO] aws_secret_name...................... '${aws_secret_name}'"
echo "[INFO] tls_ca_command_line.................. 'nomad ${tls_ca_command_line}'"
echo "[INFO] tls_cert_server_command_line......... 'nomad ${tls_cert_server_command_line}'"
echo "[INFO] tls_cert_client_command_line......... 'nomad ${tls_cert_client_command_line}'"
echo "[INFO] tls_cert_cli_command_line............ 'nomad ${tls_cert_cli_command_line}'"
echo "==========================================================================="
echo ""

# -----------------------
# EXECUTE COMMAND
# -----------------------

if aws secretsmanager describe-secret --region $aws_region --secret-id $aws_secret_name &> /dev/null; then
    echo "[WARN] the secret exists"
    exit 0
else
    echo "[INFO] the secret does not exist"
fi

nomad $tls_ca_command_line
nomad $tls_cert_server_command_line
nomad $tls_cert_client_command_line
nomad $tls_cert_cli_command_line

# -----------------------
# CREATE AWS SECRET
# -----------------------

final_json="{}"
for file in *.pem; do
    [ -f "$file" ] || continue
    filename=$(basename "$file" .pem | sed 's/-/_/g')
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

