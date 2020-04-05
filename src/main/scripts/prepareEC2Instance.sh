#!/bin/bash

EC2_PEM_KEY_PATH="$1"
WORKSPACE="$2"
PEM_KEY_NAME=thisisanfield
SECURITY_GROUP_NAME=MySecurityGroup

aws=/usr/local/bin/aws

set +e
instanceId=$(${WORKSPACE}/checkRunningEc2Instances.sh ${aws})

if [[ $instanceId ]]; then
   echo instance id is: ${instanceId}
   publicDns=$(${aws} ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
   echo ${publicDns}
else
   securityGroupId=$(${WORKSPACE}/configureSecurityGroup.sh ${aws} ${SECURITY_GROUP_NAME})
   echo security group id is: ${securityGroupId}

   region=$(${aws} configure get region)
   echo region is: ${region}

   ${WORKSPACE}/authoriseSecurityGroups.sh ${aws} ${securityGroupId} ${region}

   ${WORKSPACE}/createPemKey.sh ${aws} ${EC2_PEM_KEY_PATH} ${PEM_KEY_NAME}
   publicDns=$(${WORKSPACE}/createNewEc2Instance.sh ${aws} ${PEM_KEY_NAME} ${SECURITY_GROUP_NAME} ${region})
   echo ${publicDns}
fi

