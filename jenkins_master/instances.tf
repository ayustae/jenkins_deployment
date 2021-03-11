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
    command = templatefile("${path.module}/templates/master_provisioner.sh.tpl", { region = var.region, instance_id = self.id, module_path = path.module, rsa_key = data.external.rsa_key.result["private_key"], java_version = var.java_version })
  }
}
