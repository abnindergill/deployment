
imageName="$1"
outputfile="/home/ec2-user/scripts/temp"

echo "image name is ${imageName}" >> ${outputfile}

containerId=$(sudo docker ps | grep "${imageName}" | awk '{ print $1 }')
echo "checking if container is running ...." >> ${outputfile}
echo "container id ${containerId} found" >> ${outputfile}

if [ -n "${containerId}" ]; then
    echo "stopping container with id : $containerId" >> ${outputfile}
    echo "======================================================"
    sudo docker kill "${containerId}"
fi
sudo docker container prune -f


