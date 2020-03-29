#!/bin/bash

WORKSPACE="$1"
IMAGE_NAME="$2"
LAST_SUCCESSFUL_BUILD="$3"
BUILD_NUMBER="$4"

SCRIPTS_SRC_PATH="${WORKSPACE}/target/api/docker*.sh"
SCRIPTS_DESTINATION_FOLDER="/home/ec2-user/scripts"
PERM_KEY="/Users/abninder/aws_credentials/docker-app.pem"
EC2_INSTANCE="ec2-user@ec2-35-171-176-196.compute-1.amazonaws.com"
DOCKER_CONTAINER_STARTUP_CMD="sudo docker run -p 8082:8085 -e LISTEN_PORT=8085 ${IMAGE_NAME}:${BUILD_NUMBER}"

#copy scripts to ec2 instance
scp -i ${PERM_KEY} ${SCRIPTS_SRC_PATH} ${EC2_INSTANCE}:${SCRIPTS_DESTINATION_FOLDER}

#stop the docker container already running tagged with the last successful build number
ssh -i ${PERM_KEY} ${EC2_INSTANCE} ${SCRIPTS_DESTINATION_FOLDER}/docker-stop.sh ${IMAGE_NAME}:${LAST_SUCCESSFUL_BUILD}

#from docker hub pull down the image with the passed in buikld tag number
ssh -i ${PERM_KEY} ${EC2_INSTANCE} ${SCRIPTS_DESTINATION_FOLDER}/docker-fetch-image.sh ${IMAGE_NAME}:${BUILD_NUMBER}

#start the container for image with the passed in tag build number
ssh -i ${PERM_KEY} ${EC2_INSTANCE} ${DOCKER_CONTAINER_STARTUP_CMD}