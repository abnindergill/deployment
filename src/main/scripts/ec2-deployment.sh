#!/bin/bash

#assign passed in parameters
WORKSPACE="$1"
echo workspace is: ${WORKSPACE}

IMAGE_NAME="$2"
echo image name is: ${IMAGE_NAME}

LAST_SUCCESSFUL_BUILD="$3"
echo last successful build number is: ${LAST_SUCCESSFUL_BUILD}

BUILD_NUMBER="$4"
echo current build number is: ${BUILD_NUMBER}

EC2_PUBLIC_DNS="$5"
echo public ec2 dns is: ${EC2_PUBLIC_DNS}

PEM_KEY="$6"
echo pem key path is: ${PEM_KEY}

SCRIPTS_SRC_PATH="${WORKSPACE}/target/scripts/docker*.sh"
SCRIPTS_DESTINATION_FOLDER="/home/ec2-user/scripts"

DOCKER_CONTAINER_STARTUP_CMD="sudo docker run -p 8082:8085 -e LISTEN_PORT=8085 ${IMAGE_NAME}:${BUILD_NUMBER}"

echo creating directory ${SCRIPTS_DESTINATION_FOLDER} on ${EC2_PUBLIC_DNS} if it doesnt exist
ssh -i ${PEM_KEY} "ec2-user@${EC2_PUBLIC_DNS}" mkdir -p ${SCRIPTS_DESTINATION_FOLDER}

#copy scripts to ec2 instance
echo copying scripts from ${SCRIPTS_SRC_PATH} to ${SCRIPTS_DESTINATION_FOLDER} on ${EC2_PUBLIC_DNS}
scp -i ${PEM_KEY} ${SCRIPTS_SRC_PATH} "ec2-user@${EC2_PUBLIC_DNS}":${SCRIPTS_DESTINATION_FOLDER}

#stop the docker container already running tagged with the last successful build number
ssh -i ${PEM_KEY} "ec2-user@${EC2_PUBLIC_DNS}" ${SCRIPTS_DESTINATION_FOLDER}/docker-stop.sh ${IMAGE_NAME}:${LAST_SUCCESSFUL_BUILD}

#from docker hub pull down the image with the passed in build tag number
ssh -i ${PEM_KEY} "ec2-user@${EC2_PUBLIC_DNS}" ${SCRIPTS_DESTINATION_FOLDER}/docker-fetch-image.sh ${IMAGE_NAME}:${BUILD_NUMBER}

#start the container for image with the passed in tag build number
ssh -i ${PEM_KEY} "ec2-user@${EC2_PUBLIC_DNS}" ${DOCKER_CONTAINER_STARTUP_CMD}