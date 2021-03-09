#!/bin/bash

# Exit with error if any command fails
set -e

# If there is a 'keys' directory use it
if [[ -d keys ]]
then
    # If the key inside the 'keys' directory is wrong, delete it
    if ([[ ! -f keys/jenkins-key ]] || [[ ! -f keys/jenkins-key.pub ]])
    then
        # Delete the 'keys' directory
        rm -rf keys
        # Create it again
        mkdir keys
        # Create the RSA key pair
        ssh-keygen -C '' -t rsa -f keys/jenkins-key -P '' -q
    fi
else
    # Create the 'keys' directory if it does not exist
    mkdir keys
    # Create the RSA key pair
    ssh-keygen -C '' -t rsa -f keys/jenkins-key -P '' -q
fi

# Return a JSON object with the path to the keys
echo '{"public_key": "jenkins-key.pub", "private_key": "jenkins-key"}'
