!/bin/bash

# Exit if any command fails
set -e

# Get the swarm executable if it is not present already
if [[ ! -f swarm-client.jar ]]
then
        curl https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.9/swarm-client-3.9.jar  --output swarm-client.jar
fi

# Use the Swarm client to create Ad Hoc agents
java -jar swarm-client.jar \
        -description "Jenkins slave" \
        -executors 5 \
        -fsroot "/home/ec2-user" \
        -labels "Worker" \
        -master "http://10.0.20.55:8080" \
        -mode "normal" \
        -name "$(curl http://169.254.169.254/latest/meta-data/instance-id)" \
        -password "secret123#" \
        -username "worker_user" \
        -webSocket
