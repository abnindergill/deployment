#!/bin/bash

WORKSPACE="$1"
IMAGE_NAME="$2"
LAST_SUCCESSFUL_BUILD="$3"
BUILD_NUMBER="$4"

PEM_KEY_NAME=thisisanfield
SECURITY_GROUP_NAME=MySecurityGroup
PUBLIC_DNS

aws=/usr/local/bin/aws

set +e
instanceId=$(${WORKSPACE}/checkRunningEc2Instances.sh ${aws})

if [[ $instanceId ]]; then
   echo instance id is: ${instanceId}
   PUBLIC_DNS=$(${aws} ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
else
   securityGroupId=$(${WORKSPACE}/configureSecurityGroup.sh ${aws} ${SECURITY_GROUP_NAME})
   echo security group id is: ${securityGroupId}

   region=$(${aws} configure get region)
   echo region is: ${region}

   ${WORKSPACE}/authoriseSecurityGroups.sh ${aws} ${securityGroupId} ${region}

   ${WORKSPACE}/createPemKey.sh ${aws} ${EC2_PEM_KEY_PATH} ${PEM_KEY_NAME}
   PUBLIC_DNS=$(${WORKSPACE}/createNewEc2Instance.sh ${aws} ${PEM_KEY_NAME} ${SECURITY_GROUP_NAME} ${region})
fi

${WORKSPACE}/target/scripts/ec2-deployment.sh ${WORKSPACE} ${IMAGE_NAME} ${LAST_SUCCESSFUL_BUILD} /
${BUILD_NUMBER} ${PUBLIC_DNS} ${PEM_KEY_NAME}
\
