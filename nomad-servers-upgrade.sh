#!/bin/bash

TG_STAGE_PATH="$1"

# apply
terragrunt apply -auto-approve --terragrunt-config $TG_STAGE_PATH

# aws region
echo "[INFO] retrieve aws_region from output..."
AWS_REGION=$(terragrunt output -json --terragrunt-config $TG_STAGE_PATH | jq -r '.aws_region.value')
echo "[INFO] retrieve ssm_document_name from output..."
SSM_DOCUMENT_NAME=$(terragrunt output -json --terragrunt-config $TG_STAGE_PATH | jq -r '.ssm_document_name.value')
echo "[INFO] retrieve nomad_datacenter from output..."
NOMAD_DATACENTER=$(terragrunt output -json --terragrunt-config $TG_STAGE_PATH | jq -r '.nomad_datacenter.value')

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