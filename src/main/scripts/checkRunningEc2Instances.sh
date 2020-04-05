#!/bin/bash

aws="$1"

instanceId=$(${aws} ec2 describe-instances  --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)
if [ -z "${instanceId}" ]; then
    exit 0
fi
echo ${instanceId}
