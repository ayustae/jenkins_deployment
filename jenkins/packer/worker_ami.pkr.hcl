# Variables
variable "region" {
  type    = string
}

variable "vpc_id" {
  type    = string
}

variable "subnet_id" {
  type    = string
}

variable "instance_type" {
  type    = string
}

variable "ami_name" {
  type    = string
}

variable "ami_description" {
  type    = string
}

variable "module_path" {
  type    = string
}

# Get RHEL 8 AMI information
data "amazon-ami" "rhel" {
  most_recent = true
  region      = var.region
  owners      = ["309956199498"]
  filters     = {
    name                = "RHEL-8.*"
    virtualization-type = "hvm"
    architecture        = "x86_64"
  }
}

# Sources
source "amazon-ebs" "jenkins_worker-packer_builder" {
  # AMI configuration
  ami_name                  = var.ami_name
  ami_description           = var.ami_description
  ami_virtualization_type   = "hvm"
  force_deregister          = true
  tag {
    key     = "Name"
    value   = var.ami_name
  }
  tag {
    key     = "Type"
    value   = "AMI"
  }
  # Run configuration
  instance_type             = var.instance_type
  source_ami                = data.amazon-ami.rhel.id
  vpc_id                    = var.vpc_id
  subnet_id                 = var.subnet_id
  user_data_file            = "${var.module_path}/provisioners/bash/update_and_install_ssm.sh"
  run_tags                  = {
    Name = "jenkins_worker-packer_builder"
  }
  run_volume_tags           = {
    Name = "jenkins_worker-packer_builder"
  }
  # SSH configuration
  communicator              = "ssh"
  ssh_interface             = "public_ip"
  ssh_username              = "ec2-user"
}

# Builders
build {
  sources = ["source.amazon-ebs.jenkins_worker-packer_builder"]

  provisioner "shell" {
    script = "${var.module_path}/provisioners/bash/update_and_install_ssm.sh"
  }

  provisioner "ansible" {
    playbook_file   = "${var.module_path}/provisioners/ansible/jenkins_worker.yml"
  }
}
