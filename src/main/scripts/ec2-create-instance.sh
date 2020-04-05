#!/bin/bash

WORKSPACE="$1"
IMAGE_NAME="$2"
LAST_SUCCESSFUL_BUILD_ID="$3"
BUILD_NUMBER="$4"

EC2_PEM_KEY=/Users/abninder/aws_credentials/HelloWorld.pem

keyName=thisisanfield
securityGroup=MySecurityGroup
amiId=ami-0af3fadf16822d385

aws=/usr/local/bin/aws

#check if we have the security group already
set +e
securityGroupFound=$(${aws} ec2 describe-security-groups --group-names ${securityGroup})

#if security group does not exist then create it and add ensures that the new instance can receive traffic on ports 22 and 80
if [ -z "${securityGroupFound}" ]; then
    ${aws} ec2 create-security-group --group-name ${securityGroup} --description "My security group"
    echo "created security group ${securityGroup}"

    #get the security group id as we will need this to add rules
    securityGroupId=$(${aws} ec2 describe-security-groups --group-names ${securityGroup} --query 'SecurityGroups[*].[GroupId]' --output text)
    echo Security group id is: ${securityGroupId}

    #get the region the instance will run in
    region=$(${aws} configure get region)
    echo configuring instance for region : ${region}

    #open up port 22 for ssh
    ${aws} ec2 authorize-security-group-ingress --group-id ${securityGroupId} --protocol tcp --port 22  --cidr 0.0.0.0/0 --region ${region}
    echo "enabled ssh for security group: ${securityGroup} on port 22"

    ${aws} ec2 authorize-security-group-ingress --group-id ${securityGroupId} --protocol all --port -1  --cidr 0.0.0.0/0 --region ${region}
    echo "enabled all traffic for security group: ${securityGroup}"

    #open port 80 for http requests
    #${aws} ec2 authorize-security-group-ingress  --group-name MySecurityGroup --protocol tcp  --port 80 --cidr 0.0.0.0/0 --region ${region}
   # echo "enabled http for security group: ${securityGroup} on port 8080"

    #${aws} ec2 authorize-security-group-ingress  --group-name MySecurityGroup --protocol tcp  --port 8080 --cidr 0.0.0.0/0 --region ${region}
    #echo "enabled http for security group: ${securityGroup} on port 80"
fi

securityGroupId=$(${aws} ec2 describe-security-groups --group-names ${securityGroup} --query 'SecurityGroups[*].[GroupId]' --output text)

#check if pem key exists for key pair, if not create it and save to a file
keyPairName=$(${aws} ec2 describe-key-pairs --key-name ${keyName})
if [ -z "${keyPairName}" ]; then
    ${aws} ec2 create-key-pair --key-name ${keyName} --query 'KeyMaterial' --output text > ${EC2_PEM_KEY}
    echo created pem key for key name ${keyName}
    chmod 400 ${EC2_PEM_KEY}
fi

#check if there are any running ec2 instances
instanceId=$(${aws} ec2 describe-instances  --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)
if [ -z "${instanceId}" ]; then

    #create a new ec2 instance
    instancesInfo=$(${aws} ec2 run-instances --image-id ${amiId} --count 1 --instance-type t2.micro --key-name ${keyName} --security-groups ${securityGroup} --output json)

    #get instance id of newly created instance
    instanceId=$(${aws} ec2 describe-instances  --filters "Name=instance-state-name,Values=pending" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)
    echo newly created instanceId is : ${instanceId}

    echo waiting for instance with ${instanceId} to be ready ...
    status=$(${aws} ec2 wait --region ${region} instance-status-ok --instance-ids ${instanceId})
    echo new instance is ready
fi

#get the public dns name as we will need this for deployment
PUBLIC_DNS_NAME=$(${aws} ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
echo Public dns name is ${PUBLIC_DNS_NAME}

#deploy to ec2 and spin up the container
${WORKSPACE}/target/scripts/ec2-deployment.sh ${WORKSPACE} ${IMAGE_NAME} ${LAST_SUCCESSFUL_BUILD_ID} ${BUILD_NUMBER} ${PUBLIC_DNS_NAME} ${EC2_PEM_KEY}

