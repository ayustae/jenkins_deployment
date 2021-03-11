# Import the Jenkins master instance
data "aws_instance" "jenkins_master" {
  id = var.master_id
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
    region          = var.aws_region
    vpc_id          = aws_vpc.jenkins_vpc.id
    subnet_id       = element(aws_subnet.public_subnets.*.id, 0)
    instance_type   = var.worker_instance_type
    ami_name        = locals.worker_ami_name
    ami_description = locals.worker_ami_description
    tags            = var.tags
    module_path     = path.module
    java_version    = var.java_version
    swarm_version   = var.jenkins_swarm_version
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
    values = [locals.worker_ami_name]
  }
}

# Template file for the worker user data
data "template_file" "register_worker" {
  template = file("${path.module}/templates/register_worker.sh.tpl")
  vars = {
    master_ip   = aws_instance.jenkins_master.private_ip
    master_port = "8080"
    master_id   = aws_instance.jenkins_master.id
    username    = var.jenkins_username
    password    = var.jenkins_password
  }
}

# Create a launch template for the worker nodes
resource "aws_launch_template" "jenkins_workers_template" {
  name                     = "worker_nodes_template"
  description              = "Launch template for the worker nodes."
  image_id                 = data.aws_ami.worker_ami.id
  instance_type            = var.worker_instance_type
  key_name                 = aws_instance.jenkins_master.key_name
  vpc_security_group_names = [aws_instance.jenkins_master.vpc_security_group_ids[1]]
  iam_instance_profile     = aws_instance.jenkins_master.iam_instance_profile
  user_data                = data.template_file.register_worker.rendered
  tag_specifications = merge(
    {
      Type = "EC2 Instance"
    },
    var.tags
  )
  tags = merge(
    {
      Name = "worker_nodes-lt"
      Type = "Launch Template"
    },
    var.tags
  )
  depends_on = [null_resource.worker_ami]
}

# Create an autoscaling group
resource "aws_autoscaling_group" "jenkins_workers" {
  name                      = "jenkins_workers-asg"
  max_size                  = var.max_amount_workers
  min_size                  = var.min_amount_workers
  vpc_zone_identifier       = [for subnet in aws_subnet.private_subnets : subnet.id]
  health_check_grace_period = 120
  health_check_type         = "EC2"
  default_cooldown          = 150
  force_delete              = false
  capacity_rebalance        = true
  tags = concat(
    list(
      {
        "key"                 = "Name"
        "value"               = "jenkins_workers-asg"
        "propagate_at_launch" = false
      },
      {
        "key"                 = "Type"
        "value"               = "Autoscaling Group"
        "propagate_at_launch" = false
      },
      [
        for tag in var.tags : {
          "key"                 = tag.key
          "value"               = tag.value
          "propagate_at_launch" = false
        }
      ]
    )
  )
  launch_template {
    id      = aws_launch_template.jenkins_workers_template.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.jenkins_workers_template]
}

# Scale Up Autoscaling policy
resources "aws_autoscaling_policy" "scale_up" {
  name                   = "jenkins_workers-scale_up_policy"
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
  adjustement_type       = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustement    = "+1"

}

# Scale Down Autoscaling policy
resources "aws_autoscaling_policy" "scale_down" {
  name                   = "jenkins_workers-scale_down_policy"
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
  adjustement_type       = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustement    = "-1"
}
