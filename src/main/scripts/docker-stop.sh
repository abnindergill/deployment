
imageName="$1"
logFile="/home/ec2-user/scripts/temp"

echo "image name is ${imageName}" >> ${logFile}

containerId=$(sudo docker ps | grep "${imageName}" | awk '{ print $1 }')
echo "checking if container is running ...." >> ${logFile}
echo "container id ${containerId} found" >> ${logFile}

if [ -n "${containerId}" ]; then
    echo "stopping container with id : $containerId" >> ${logFile}
    echo "======================================================"
    sudo docker kill "${containerId}"
fi
sudo docker container prune -f


