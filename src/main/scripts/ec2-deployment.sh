#!/bin/bash

echo workspace is ${WORKSPACE}
echo image name is ${IMAGE_NAME}
echo last successful build is ${LAST_SUCCESSFUL_BUILD}
echo build number is ${BUILD_NUMBER}
echo public dns is ${PUBLIC_DNS}
echo pem key path is ${EC2_PEM_KEY_PATH}

SCRIPTS_SRC_PATH="${WORKSPACE}/docker*.sh"
SCRIPTS_DESTINATION_FOLDER="/home/ec2-user/scripts"

DOCKER_CONTAINER_STARTUP_CMD="sudo docker run -p 8082:8085 -e LISTEN_PORT=8085 ${IMAGE_NAME}:${BUILD_NUMBER}"

if ! grep "$(ssh-keyscan ${PUBLIC_DNS} 2>/dev/null)" ~/.ssh/known_hosts > /dev/null; then
    ssh-keyscan ${PUBLIC_DNS} >> ~/.ssh/known_hosts
fi

echo creating directory ${SCRIPTS_DESTINATION_FOLDER} on ${EC2_PUBLIC_DNS} if it doesnt exist
ssh -i ${EC2_PEM_KEY_PATH} "ec2-user@${EC2_PUBLIC_DNS}" mkdir -p ${SCRIPTS_DESTINATION_FOLDER}

#copy scripts to ec2 instance
echo copying scripts from ${SCRIPTS_SRC_PATH} to ${SCRIPTS_DESTINATION_FOLDER} on ${EC2_PUBLIC_DNS}
scp -i ${EC2_PEM_KEY_PATH} ${SCRIPTS_SRC_PATH} "ec2-user@${EC2_PUBLIC_DNS}":${SCRIPTS_DESTINATION_FOLDER}

#stop the docker container already running tagged with the last successful build number
ssh -i ${EC2_PEM_KEY_PATH} "ec2-user@${EC2_PUBLIC_DNS}" ${SCRIPTS_DESTINATION_FOLDER}/docker-stop.sh ${IMAGE_NAME}:${LAST_SUCCESSFUL_BUILD}

#from docker hub pull down the image with the passed in build tag number
ssh -i ${EC2_PEM_KEY_PATH} "ec2-user@${EC2_PUBLIC_DNS}" ${SCRIPTS_DESTINATION_FOLDER}/docker-fetch-image.sh ${IMAGE_NAME}:${BUILD_NUMBER}

#start the container for image with the passed in tag build number
ssh -i ${EC2_PEM_KEY_PATH} "ec2-user@${EC2_PUBLIC_DNS}" ${DOCKER_CONTAINER_STARTUP_CMD}