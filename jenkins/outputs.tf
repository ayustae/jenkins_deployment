output "jenkins_url" {
  value = aws_route53_record.jenkins_lb.fqdn
}

output "jenkins_vpc_id" {
  value = aws_vpc.jenkins_vpc.id
}

output "jenkins_public_subnets" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "jenkins_private_subnets" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "jenkins_master_sg_id" {
  value = aws_security_group.jenkins_master-sg.id
}
