#!/bin/bash

aws="$1"
securityGroupId="$2"
region="$3"

${aws} ec2 authorize-security-group-ingress --group-id ${securityGroupId} --protocol tcp --port 22  --cidr 0.0.0.0/0 --region ${region}
echo "enabled ssh for security group id: ${securityGroupId} on port 22"

${aws} ec2 authorize-security-group-ingress --group-id ${securityGroupId} --protocol all --port -1  --cidr 0.0.0.0/0 --region ${region}
echo "enabled all traffic for security group id: ${securityGroupId}"

