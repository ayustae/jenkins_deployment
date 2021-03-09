# Get the already existing hosted zones
data "aws_route53_zone" "dns" {
  name = var.dns_domain
}

# Create a certificate for the Jenkins server domain name
resource "aws_acm_certificate" "jenkins_https_cert" {
  domain_name       = join(".", [var.subdomain, data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags               = {
    Name = "jenkins_ssl_cert"
    Type = "SSL Certificate"
    for tag in var.tags: tak.key => tag.value
  }
}

# Create record for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for value in aws_acm_certificate.jenkins_https_cert.domain_validation_options : value.domain_name => {
      name   = value.resource_record_name
      record = value.resource_record_value
      type   = value.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns.zone_id
}

# Validate the certificate via Route53
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.jenkins_https_cert.arn
  for_each                = aws_route53_record.cert_validation
  validation_record_fqdns = [aws_route53_record.cert_validation[each.key].fqdn]
}

# Create Alias record for the LB DNS record
resource "aws_route53_record" "jenkins_lb" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = join(".", [var.subdomain, data.aws_route53_zone.dns.name])
  type    = "A"
  alias {
    name                   = aws_lb.jenkins_lb.dns_name
    zone_id                = aws_lb.jenkins_lb.zone_id
    evaluate_target_health = true
  }
}
