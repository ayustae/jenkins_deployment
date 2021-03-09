output "vpc_id" {
  value = module.jenkins_master.jenkins_vpc_id
}

output "jenkins_url" {
  value = module.jenkins_master.jenkins_url
}
