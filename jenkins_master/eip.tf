# Create public IPs for the NAT gateways
resource "aws_eip" "nat_ips" {
  count      = 3
  vpc        = true
  tags       = {
    Name = "jenkins_eip_${count.index + 1}"
    Type = "EIP"
    for tag in var.tags: tag.key => tag.value
  }
  depends_on = [aws_internet_gateway.jenkins_igw]
}
