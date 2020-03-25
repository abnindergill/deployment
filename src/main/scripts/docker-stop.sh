#!/bin/bash
echo "checking if container is running ...." > /tmp/testfile

containerId=$(docker ps | grep 'abninder/test-image' | awk '{ print $1 }')
echo "container id $containerId found" > /tmp/testfile

if [ -n "${containerId}" ]; then
    echo "stopping container with id : $containerId" > /tmp/testfile
    docker kill "$containerId"
fi


