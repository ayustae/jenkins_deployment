#!/bin/bash

# Create the temporary Ansible inventory
sed -i "" "s/i-[a-z0-9]*/${instance_id}/" "${module_path}/provisioners/ansible/inventory.ini"

# Wait until the instance in scope is ready
aws ec2 wait instance-status-ok --region "${region}" --instance-ids "${instance_id}"

# Wait some seconds for the system to initialize
sleep 30

# Run the ansible playbook
ansible-playbook \
    --user 'ec2-user' \
    --become-user 'root' \
    --inventory "${module_path}/provisioners/ansible/inventory.ini" \
    --private-key "${module_path}/keys/${rsa_key}" \
    --extra-vars "module_path=${module_path}" \
    "${module_path}/provisioners/ansible/jenkins_master.yml"
