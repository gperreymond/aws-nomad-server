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

# apply
terragrunt apply -auto-approve --terragrunt-config "${stage}"

# aws region
echo "[INFO] retrieve terraform output from terragrunt"
outputs=$(terragrunt output -json --terragrunt-config "${stage}")
AWS_REGION=$(echo $outputs | jq -r '.aws_region.value')
SSM_DOCUMENT_NAME=$(echo $outputs | jq -r '.ssm_document_name.value')
NOMAD_DATACENTER=$(echo $outputs | jq -r '.nomad_datacenter.value')

# -----------------------
# RESUME
# -----------------------

echo ""
echo "============================================================="
echo "[INFO] AWS_REGION.................. $AWS_REGION"
echo "[INFO] SSM_DOCUMENT_NAME........... $SSM_DOCUMENT_NAME"
echo "[INFO] NOMAD_DATACENTER............ $NOMAD_DATACENTER"
echo "============================================================="
echo ""


# get all instances ids from tags
echo "[INFO] try to find instances..."
instance_ids=$(aws ec2 describe-instances --region $AWS_REGION \
                --filters "Name=tag:NomadDatacenter,Values=$NOMAD_DATACENTER" "Name=tag:NomadType,Values=server" "Name=instance-state-name,Values=running" \
                --query 'Reservations[*].Instances[*].InstanceId' \
                --output text)

# send ssm command on those instances
if [ -z "$instance_ids" ]; then
  echo "[WARN] no instance found with tags!"
else
  echo "[INFO] instances found"
  aws ssm send-command --instance-ids ${instance_ids} --region $AWS_REGION --document-name $SSM_DOCUMENT_NAME
fi

# -----------------------
# END
# -----------------------

echo ""
