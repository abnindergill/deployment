#!/bin/bash
EC2_PEM_KEY_PATH=/Users/abninder/aws_credentials/HelloWorld.pem
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

   # shellcheck disable=SC2034
   security_group_id=$(./authoriseSecurityGroup.sh ${aws} ${securityGroupId} ${region})
   ./createPemKey.sh ${aws} ${EC2_PEM_KEY_PATH} ${PEM_KEY_NAME}

   echo waiting for new ec2 instance to be ready ...
   id_dns=$(./createNewEc2Instance.sh ${aws} ${PEM_KEY_NAME} ${SECURITY_GROUP_NAME} ${region})
   echo ${id_dns}
fi

#deploy to the newly created ec2 instance and spin up the container
${WORKSPACE}/target/scripts/ec2-deployment.sh ${WORKSPACE} ${IMAGE_NAME} ${LAST_SUCCESSFUL_BUILD_ID} ${BUILD_NUMBER} ${PUBLIC_DNS_NAME} ${EC2_PEM_KEY}
exit $?

