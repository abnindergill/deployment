#!/bin/bash

aws="$1"
security_group_name="$2"

securityGroupFound=$(${aws} ec2 describe-security-groups --group-names ${security_group_name})
if [ -z "${securityGroupFound}" ]; then
    ${aws} ec2 create-security-group --group-name ${security_group_name} --description "My security group"
    echo "created security group ${security_group_name}"
fi

securityGroupId=$(${aws} ec2 describe-security-groups --group-names ${security_group_name} --query 'SecurityGroups[*].[GroupId]' --output text)
echo ${securityGroupId}
