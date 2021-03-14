#!/bin/bash

# Exit in case of any error
set -e

# Use packer to create the worker ami
packer build \
    -var "region=${region}" \
    -var "vpc_id=${vpc_id}" \
    -var "subnet_id=${subnet_id}" \
    -var "instance_type=${instance_type}" \
    -var "ami_name=${ami_name}" \
    -var "ami_description=${ami_description}" \
    -var "module_path=${module_path}" \
    "${module_path}/packer/worker_ami.pkr.hcl"
