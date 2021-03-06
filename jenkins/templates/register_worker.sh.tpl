#!/bin/bash

# Exit if any command fails
set -e

# Use the Swarm client to create ad-hoc agents
java -jar /home/ec2-user/swarm-client.jar \
    -description "Jenkins ad-hoc slave" \
    -executors 5 \
    -fsroot "/home/ec2-user" \
    -labels "General" \
    -master "http://${master_ip}:${master_port}" \
    -mode "normal" \
    -name "$(curl http://169.254.169.254/latest/meta-data/instance-id)" \
    -password "${password}" \
    -username "${username}" \
    -webSocket
