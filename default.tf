# AWS configuration variables
variable "aws_region" {
  description = "AWS region where the deployment will take place"
  type        = string
  default     = "eu-central-1"
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

# Networking configuration
variable "network_ip" {
  description = "IP octects for the VPC network (2 first octects of the VPC CIDR)"
  type        = string
  default     = "10.0"
}

# Jenkins master webserver port
variable "webserver_port" {
  description = "Port of the webserver in the Jenkins master"
  type        = string
  default     = "8080"
}

# DNS configuration
variable "dns_domain" {
  description = "Apex domain name to create subdomains"
  type        = string
  default     = "example.com."
}

variable "subdomain" {
  description = "DNS subdomain for the Jenkins web console"
  type        = string
  default     = "jenkins"
}

# Instance types
variable "master_instance_type" {
  description = "Jenkins master instance type"
  type        = string
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "Jenkins worker instance type"
  type        = string
  default     = "t2.medium"
}

# Min number of worker nodes
variable "min_amount_workers" {
  description = "Amount of worker nodes to deploy"
  type        = number
  default     = 2
}

# Max number of worker nodes
variable "max_amount_workers" {
  description = "Amount of worker nodes to scale"
  type        = number
  default     = 3
}

# Java version
variable "java_version" {
  description = "Java version to be used"
  type        = string
  default     = "8.0"
}

# Jenkins swarm plugin version
variable "jenkins_swarm_version" {
  description = "Jenkins swarm plugin version"
  type        = string
  default     = "3.9"
}

# Jenkins username for registering workers
variable "jenkins_username" {
  description = "Jenkins technical username for registering workers"
  type        = string
  default     = "worker_user"
}

# Jenkins password for registering workers
variable "jenkins_password" {
  description = "Jenkins technical user password for registering workers"
  type        = string
  default     = "Password123#"
}
