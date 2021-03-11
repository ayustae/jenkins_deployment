# AWS region
variable "region" {
  description = "AWS region where the deployment will take place"
  type        = string
}

# Project tag
variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

# VPC CIDR block
variable "network_ip" {
  description = "IP octects for the VPC network (2 first octects of the VPC CIDR)"
  type        = string
}

# Jenkins master webserver port
variable "webserver_port" {
  description = "Port of the webserver in the Jenkins master"
  type        = string
}

# Domain name to be used to create Route53 registries
variable "dns_domain" {
  description = "Apex domain name to create subdomains"
  type        = string
}

# Subdomain below the DNS record for the Jenkins web console
variable "subdomain" {
  description = "DNS subdomain for the Jenkins web console"
  type        = string
}

# Jenkins master instance type
variable "master_instance_type" {
  description = "Jenkins master instance type"
  type        = string
}

# Java version
variable "java_version" {
  description = "Java versiont to use"
  type        = string
}
