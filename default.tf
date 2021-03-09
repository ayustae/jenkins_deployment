# AWS configuration variables
variable "aws_region" {
  description = "AWS region where the deployment will take place"
  type        = string
  default     = "us-east-1"
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
  default     = "some-example.com."
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
  default     = "t2.micro"
}

variable "worker_instance_type" {
  description = "Jenkins worker instance type"
  type        = string
  default     = "t2.micro"
}

# Min number of worker nodes
variable "amount_workers" {
  description = "Amount of worker nodes to deploy"
  type        = number
  default     = 2
}

# Max number of worker nodes
variable "scale_workers" {
  description = "Amount of worker nodes to scale"
  type        = number
  default     = 3
}
