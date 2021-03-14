#!/bin/bash

# Exit in case of any error
set -e

# Create the temporary Ansible inventory
sed -i "" "s/i-[a-z0-9]*/${instance_id}/" "${module_path}/provisioners/ansible/inventory.ini"

# Wait until the instance in scope is ready
aws ec2 wait instance-status-ok --region "${region}" --instance-ids "${instance_id}"

# Wait some seconds for the system to initialize
sleep 60

# Check SSH connectivity
echo ssh -o \"StrictHostKeyChecking=no\" -o ProxyCommand=\"sh -c \\\"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\\\"\" -i "${module_path}/keys/${rsa_key}" ec2-user@"${instance_id}" echo 'Hey there!'
ssh -o StrictHostKeyChecking=no -o ProxyCommand="sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"" -i "${module_path}/keys/${rsa_key}" ec2-user@"${instance_id}" echo 'Hey there!'

# Run the ansible playbook
ansible-playbook \
    --user 'ec2-user' \
    --become-user 'root' \
    --inventory "${module_path}/provisioners/ansible/inventory.ini" \
    --private-key "${module_path}/keys/${rsa_key}" \
    --extra-vars "module_path=${module_path}" \
    "${module_path}/provisioners/ansible/jenkins_master.yml"
