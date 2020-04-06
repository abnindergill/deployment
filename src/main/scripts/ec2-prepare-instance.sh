#!/bin/bash

WORKSPACE="$1"
IMAGE_NAME="$2"
LAST_SUCCESSFUL_BUILD="$3"
BUILD_NUMBER="$4"

PEM_KEY_NAME=thisisanfield
SECURITY_GROUP_NAME=MySecurityGroup
EC2_PEM_KEY_PATH=/Users/abninder/aws_credentials/HelloWorld.pem
EC2_PUBLIC_DNS=""

aws=/usr/local/bin/aws

set +e
instanceId=$(${WORKSPACE}/checkRunningEc2Instances.sh ${aws})

if [[ $instanceId ]]; then
   echo instance id is: ${instanceId}
   EC2_PUBLIC_DNS=$(${aws} ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
else

   securityGroupId=$(${WORKSPACE}/configureSecurityGroup.sh ${aws} ${SECURITY_GROUP_NAME})
   echo security group id is: ${securityGroupId}

   region=$(${aws} configure get region)
   echo region is: ${region}

   ${WORKSPACE}/authoriseSecurityGroups.sh ${aws} ${securityGroupId} ${region}

   ${WORKSPACE}/createPemKey.sh ${aws} ${EC2_PEM_KEY_PATH} ${PEM_KEY_NAME}

   echo preparing new instance and waiting for it to be ready ...
   EC2_PUBLIC_DNS=$(${WORKSPACE}/createNewEc2Instance.sh ${aws} ${PEM_KEY_NAME} ${SECURITY_GROUP_NAME} ${region})
fi

export WORKSPACE
export IMAGE_NAME
export LAST_SUCCESSFUL_BUILD
export BUILD_NUMBER
export EC2_PUBLIC_DNS
export EC2_PEM_KEY_PATH

${WORKSPACE}/ec2-deployment.sh

