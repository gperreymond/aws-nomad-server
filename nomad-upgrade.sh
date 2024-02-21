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
ssm_document_name=$(echo $outputs | jq -r '.ssm_document_name.value')
nomad_region=$(echo $outputs | jq -r '.nomad_region.value')
nomad_datacenter=$(echo $outputs | jq -r '.nomad_datacenter.value')

# -----------------------
# RESUME
# -----------------------

echo ""
echo "============================================================="
echo "[INFO] aws_region.................. $aws_region"
echo "[INFO] ssm_document_name........... $ssm_document_name"
echo "[INFO] nomad_region................ $nomad_region"
echo "[INFO] nomad_datacenter............ $nomad_datacenter"
echo "============================================================="
echo ""

# get all instances ids from tags
echo "[INFO] try to find instances..."
instance_ids=$(aws ec2 describe-instances --region $aws_region \
                --filters "Name=tag:NomadRegion,Values=$nomad_region" "Name=tag:NomadDatacenter,Values=$nomad_datacenter" "Name=tag:NomadType,Values=server" "Name=instance-state-name,Values=running" \
                --query 'Reservations[*].Instances[*].InstanceId' \
                --output text)

# send ssm command on those instances
if [ -z "$instance_ids" ]; then
  echo "[WARN] no instance found with tags!"
else
  echo "[INFO] instances found"
  aws ssm send-command --instance-ids ${instance_ids} --region $aws_region --document-name $ssm_document_name
fi

# -----------------------
# END
# -----------------------

echo ""
