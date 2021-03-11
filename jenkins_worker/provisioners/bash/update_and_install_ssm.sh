#!/bin/bash

# Update the system
sudo yum update -y

# Install SSM
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Start SSM Agent
sudo systemctl start amazon-ssm-agent

# Enable SSM Agent
sudo systemctl enable amazon-ssm-agent
