#!/bin/bash

aws="$1"
pem_key_path="$2"
pem_key_name="$3"

keyPairName=$(${aws} ec2 describe-key-pairs --key-name ${pem_key_name})
if [ -z "${keyPairName}" ]; then
    ${aws} ec2 create-key-pair --key-name ${pem_key_name} --query 'KeyMaterial' --output text > ${pem_key_path}
    echo created pem key for key name: ${pem_key_name} in path: ${pem_key_path}
    chmod 400 ${pem_key_path}
fi

exit $?
