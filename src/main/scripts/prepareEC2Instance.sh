#!/bin/bash

EC2_PEM_KEY_PATH="$1"
PEM_KEY_NAME=thisisanfield
SECURITY_GROUP_NAME=MySecurityGroup

aws=/usr/local/bin/aws

set +e
instanceId=$(./checkRunningEc2Instances.sh aws)


if [[ $instanceId ]]; then
   echo instance id is: ${instanceId}
   publicDns=$(${aws} ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
   echo public dns is: ${publicDns}
else
   securityGroupId=$(./configureSecurityGroup.sh ${aws} ${SECURITY_GROUP_NAME})
   echo security group id is: ${securityGroupId}

   region=$(${aws} configure get region)
   echo region is: ${region}

   ./authoriseSecurityGroups.sh ${aws} ${securityGroupId} ${region}

   ./createPemKey.sh ${aws} ${EC2_PEM_KEY_PATH} ${PEM_KEY_NAME}
   dns=$(./createNewEc2Instance.sh ${aws} ${PEM_KEY_NAME} ${SECURITY_GROUP_NAME} ${region})
   echo ${dns}
fi

