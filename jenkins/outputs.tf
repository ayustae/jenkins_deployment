output "jenkins_url" {
  value = aws_route53_record.jenkins_lb.fqdn
}

output "jenkins_vpc_id" {
  value = aws_vpc.jenkins_vpc.id
}

output "jenkins_master_id" {
  value = aws_instance.jenkins_master.id
}
