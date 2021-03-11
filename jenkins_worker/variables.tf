# AWS configuration variables
variable "aws_region" {
  description = "AWS region where the deployment will take place"
  type        = string
}

# Tagging configuration
variable "tags" {
  description = "Tags for the created resources"
  type        = map(string)
  default = {
    Project = "MyProject"
    Group   = "jenkins"
  }
}

# Instance type for the worker nodes
variable "worker_instance_type" {
  description = "Jenkins worker instance type"
  type        = string
}

# Min number of worker nodes
variable "min_amount_workers" {
  description = "Amount of worker nodes to deploy"
  type        = number
}

# Max number of worker nodes
variable "max_amount_workers" {
  description = "Amount of worker nodes to scale"
  type        = number
}

# VPC Id
variable "vpc_id" {
  description = "VPC Id to tdeploy the workers to."
  type        = string
}

# Master node Id
variable "master_id" {
  description = "Id of the instance of the master node"
  type        = string
}

# Java version
variable "java_version" {
  description = "Java version to be used"
  type        = string
}

# Jenkins swarm version
variable "jenkins_swarm_version" {
  description = "Jenkins swarm version to use"
  type        = string
}

# Jenkins username
variable "jenkins_username" {
  description = "Jenkins technical username to add workers"
  type        = string
}

# Jenkins password
variable "jenkins_password" {
  description = "Jenkins technical user password to add workers"
  type        = string
}
