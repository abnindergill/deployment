#!/bin/bash

imageName="$1"

containerId=$(docker ps | grep "${imageName}" | awk '{ print $1 }')
echo "checking if container is running ...." >> /tmp/testfile
echo "container id ${containerId} found" >> /tmp/testfile

if [ -n "${containerId}" ]; then
    echo "stopping container with id : $containerId" >> /tmp/testfile
    echo "======================================================"
    docker kill "$containerId"
fi


