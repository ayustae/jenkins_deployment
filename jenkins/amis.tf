# Get RHEL 8 AMI information
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-8.*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Create the worker AMI name
locals {
  worker_ami_name        = "jenkins-worker-ami"
  worker_ami_description = "AMI to be used to deploy Jenkins workers based on RHEL 8."
}

# Prepare the packer executor
data "template_file" "packer_executor" {
  template = file("${path.module}/templates/worker_provisioner.sh.tpl")
  vars = {
    region          = var.region
    vpc_id          = aws_vpc.jenkins_vpc.id
    subnet_id       = element(aws_subnet.public_subnets.*.id, 0)
    instance_type   = var.worker_instance_type
    ami_name        = local.worker_ami_name
    ami_description = local.worker_ami_description
    module_path     = path.module
  }
}

# Execute packer to create the worker AMI
resource "null_resource" "worker_ami" {
  provisioner "local-exec" {
    command = data.template_file.packer_executor.rendered
  }
}

# Get the Id of the new AMI
data "aws_ami" "worker_ami" {
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "name"
    values = [local.worker_ami_name]
  }
  depends_on = [null_resource.worker_ami]
}
