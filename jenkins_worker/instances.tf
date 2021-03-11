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
resource "null_resource" "worker_ami" {
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

# Create a launch template for the worker nodes
resource "aws_launch_template" "worker_nodes_template" {
  name                      = "worker_nodes_template"
  description               = "Launch template for the worker nodes."
  image_id                  = data.aws_ami.worker_ami.id
  instance_type             = var.worker_instance_type
  key_name                  = aws_instance.jenkins_master.key_name
  vpc_security_group_names  = [aws_instance.jenkins_master.vpc_security_group_ids[1]]
  iam_instance_profile      = aws_instance.jenkins_master.iam_instance_profile
  user_data                 = file("${path.module}/provisioners/bash/update_and_register_worker.sh")
  tag_specifications        = merge(
  {
    Type = "EC2 Instance"
  },
  var.tags
  )
  tags                      = merge(
  {
    Name = "worker_nodes-lt"
    Type = "Launch Template"
  },
  var.tags
  )
  depends_on = [null_resource.worker_ami]
}

# Create an autoscaling group

