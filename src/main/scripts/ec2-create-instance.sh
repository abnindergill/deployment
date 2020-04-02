#!/bin/bash

keyName=thisisanfield
securityGroup=MySecurityGroup
amiId=ami-0af3fadf16822d385

#get the region the instance will run in
region=$(aws configure get region)
echo configuring instance for region : ${region}

#check if we have the security group already
securityGroupFound=$(aws ec2 describe-security-groups --group-names ${securityGroup})

#if security group does not exist then create it and add ensures that the new instance can receive traffic on ports 22 and 80
if [ -z "${securityGroupFound}" ]; then
    aws ec2 create-security-group --group-name ${securityGroup} --description "My security group"
    echo "created security group ${securityGroup}"

    #get the security group id as we will need this to add rules
    securityGroupId=$(aws ec2 describe-security-groups --group-names ${securityGroup} --query 'SecurityGroups[*].[GroupId]' --output text)
    echo Security group id is: ${securityGroupId}

    #open up port 22 for ssh
    aws ec2 authorize-security-group-ingress --group-id ${securityGroupId} --protocol tcp --port 22  --cidr 0.0.0.0/0 --region ${region}
    echo "enabled ssh for security group: ${securityGroup} on port 22"

    #open port 80 for http requests
    aws ec2 authorize-security-group-ingress  --group-name MySecurityGroup --protocol tcp  --port 80 --cidr 0.0.0.0/0
    echo "enabled http for security group: ${securityGroup} on port 80"
fi

securityGroupId=$(aws ec2 describe-security-groups --group-names ${securityGroup} --query 'SecurityGroups[*].[GroupId]' --output text)

#check if pem key exists for key pair, if not create it and save to a file
keyPairName=$(aws ec2 describe-key-pairs --key-name ${keyName})
if [ -z "${keyPairName}" ]; then
    aws ec2 create-key-pair --key-name ${keyName} --query 'KeyMaterial' --output text > /Users/abninder/aws_credentials/HelloWorld.pem
    echo created pem key for key name ${keyName}
    chmod 400 /Users/abninder/aws_credentials/HelloWorld.pem
fi

#check if there are any running ec2 instances
instanceId=$(aws ec2 describe-instances  --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)
if [ -z "${instanceId}" ]; then
    #create a new ec2 instance
    instancesInfo=$(aws ec2 run-instances --image-id ${amiId} --count 1 --instance-type t2.micro --key-name ${keyName} --security-groups ${securityGroup} --output json)
    echo status is : ${instancesInfo}

    #get instance id of newly created instance
    instanceId=$(aws ec2 describe-instances  --filters "Name=instance-state-name,Values=pending" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text)

    echo waiting for new instance to be ready ...
    status=$(aws ec2 wait --region ${region} instance-status-ok --instance-ids ${instanceId})
    echo new instance is ready
fi

#get the public dns name as we will need this for deployment
publicDnsName=$(aws ec2 describe-instances --instance-ids ${instanceId} --query 'Reservations[].Instances[].PublicDnsName' --output text)
export EC2_HOST_NAME=${publicDnsName}
export INSTANCE_ID=${instanceId}

