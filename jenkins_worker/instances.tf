# Import the Jenkins master instance
data "aws_instance" "jenkins_master" {
  id = var.master_id
}

# Create the worker AMI name
locals {
  worker_ami_name           = "jenkins-worker-ami"
  worker_ami_description    = "AMI to be used to deploy Jenkins workers based on RHEL 8."
}

# Prepare the packer executor
data "template_file" "packer_executor" {
  template = file("${path.module}/templates/worker_provisioner.sh")
  vars     = {
    region          = var.aws_region
    vpc_id          = aws_vpc.jenkins_vpc.id
    subnet_id       = element(aws_subnet.public_subnets.*.id, 0)
    instance_type   = var.worker_instance_type
    ami_name        = locals.worker_ami_name
    ami_description = locals.worker_ami_description
    tags            = var.tags
    module_path     = path.module
  }
}

# Execute packer to create the worker AMI
resource "null_resource" "create_worker_ami" {
  provisioner "local-exec" {
    command = data.template_file.packer_executor.rendered
  }
}

# Get the Id of the new AMI
data "aws_ami" "worker_ami" {
  owners            = ["self"]
  most_recent       = true
  filter {
    name    = "name"
    values  = [locals.worker_ami_name]
  }
}
