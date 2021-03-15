# Create the vault password file
resource "null_resource" "vault_password" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/templates/create_vault_password_file.sh.tpl", { vault_password = var.vault_password, module_path = path.module })
  }
}

# Create a RSA key pair
data "external" "rsa_key" {
  program     = ["bash", "data_sources/create_key_pair.sh"]
  working_dir = path.module
  query = {
  }
}

# Upload the key pair to AWS
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = file("${path.module}/keys/${data.external.rsa_key.result["public_key"]}")
  tags = merge(
    {
      Name = "jenkins_ssh_key"
      Type = "Key Pair"
    },
    var.tags
  )
}

# Create instance profile for the jenkins instances
resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins_profile"
  role = aws_iam_role.ssm_role.name
}

# Create the Jenkins master instance
resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.rhel.id
  instance_type               = var.master_instance_type
  key_name                    = aws_key_pair.jenkins_key.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.jenkins_master-sg.id, aws_security_group.jenkins_worker-sg.id]
  subnet_id                   = element(aws_subnet.private_subnets.*.id, 0)
  iam_instance_profile        = aws_iam_instance_profile.jenkins_instance_profile.id
  user_data                   = file("${path.module}/provisioners/bash/update_and_install_ssm.sh")
  tags = merge(
    {
      Name = "jenkins_master_instance"
      Type = "EC2 Instance"
    },
    var.tags
  )
  depends_on = [aws_route_table_association.private_routes_assoc]
  provisioner "local-exec" {
    command = templatefile("${path.module}/templates/master_provisioner.sh.tpl", { region = var.region, instance_id = self.id, module_path = path.module, rsa_key = data.external.rsa_key.result["private_key"] })
  }
}

# Create a launch template for the worker nodes
resource "aws_launch_template" "jenkins_workers_template" {
  name                   = "worker_nodes_template"
  description            = "Launch template for the worker nodes."
  image_id               = data.aws_ami.worker_ami.id
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.jenkins_key.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_worker-sg.id]
  user_data              = base64encode(file("${path.module}/provisioners/bash/run_worker_registration.sh"))
  iam_instance_profile {
    arn = aws_iam_instance_profile.jenkins_instance_profile.arn
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "jenkins_worker_instance"
        Type = "EC2 Instance"
      },
      var.tags
    )
  }
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
      }
    ),
    [
      for key in keys(var.tags) : {
        "key"                 = key
        "value"               = lookup(var.tags, key)
        "propagate_at_launch" = false
      }
    ]
  )
  launch_template {
    id      = aws_launch_template.jenkins_workers_template.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.jenkins_workers_template]
}

# Scale Up Autoscaling policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "jenkins_workers-scale_up_policy"
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "+1"

}

# Scale Down Autoscaling policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "jenkins_workers-scale_down_policy"
  autoscaling_group_name = aws_autoscaling_group.jenkins_workers.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = "-1"
}
