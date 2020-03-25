#!/bin/bash
echo "HELLO WORLD" > /tmp/testfile

containerId=$(docker ps | grep 'abninder/test-image' | awk '{ print $1 }')

echo "checking if container is running ...."
if [ -n "${containerId}" ]; then
    echo "stopping container with id : $containerId"
    docker kill "$containerId"
fi


