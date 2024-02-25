#!/bin/bash


NOMAD_API_URL="http://localhost:4646/v1"

jobs_ids=$(curl -s "${NOMAD_API_URL}/jobs" | jq -r '.[].ID')
for job_id in $jobs_ids; do
    job_services=$(curl -s "${NOMAD_API_URL}/job/${job_id}/services")
    echo $job_services | jq
    for service in $job_services; do
        service_name=$(echo $service | jq -r '.Name')
        echo "[INFO] service \"$service_name\""
    done
done