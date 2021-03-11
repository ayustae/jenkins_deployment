# Terraform configuration
terraform {
  backend "s3" {
    encrypt = true
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Load master jenkins module
module "jenkins_master" {
  source = "./jenkins_master/"
  # variables
  region               = var.aws_region
  tags                 = var.tags
  network_ip           = var.network_ip
  webserver_port       = var.webserver_port
  dns_domain           = var.dns_domain
  subdomain            = var.subdomain
  master_instance_type = var.master_instance_type
}
