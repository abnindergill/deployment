#!/bin/bash

aws="$1"
key_name="$2"
security_group_name="$3"
region="$4"

amiId=ami-0af3fadf16822d385

# shellcheck disable=SC2034
instancesInfo=$(${aws} ec2 run-instances --image-id ${amiId} --count 1 --instance-type t2.micro --key-name ${key_name} --security-groups ${security_group_name} --output json)

instanceId=$(${aws} ec2 describe-instances  --filters "Name=instance-state-name,Values=pending" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)

# shellcheck disable=SC2034
status=$(${aws} ec2 wait --region ${region} instance-status-ok --instance-ids ${instanceId})

public_dns_name=$(${aws} ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
echo ${public_dns_name}
