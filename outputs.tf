output "vpc_id" {
  value = module.jenkins.jenkins_vpc_id
}

output "jenkins_master_id" {
  value = module.jenkins.jenkins_master_id
}

output "jenkins_url" {
  value = module.jenkins.jenkins_url
}
