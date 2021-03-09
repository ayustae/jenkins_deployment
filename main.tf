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

# Load the worker jenkins module
# The master needs to be deployed and configured before the workers are deployed
#module "jenkins_workers" {
#  source "./jenkins_workers/"
#  # variables
#  region               = var.aws_region
#  tags                 = var.tags
#  vpc_id               = module.jenkins_master.jenkins_vpc_id
#  public_subnets       = module.jenkins_master.jenkins_public_subnets
#  private_subnets      = module.jenkins_master.jenkins_private_subnets
#  master_sg            = module.jenkins_master.jenkins_master_sg_id
#  worker_instance_type = var.worker_instance_type
#  min_amount_workers   = var.amount_workers
#  max_amount_workers   = var.scale_workers
#}
