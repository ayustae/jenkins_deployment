# Create public IPs for the NAT gateways
resource "aws_eip" "nat_ips" {
  count = 3
  vpc   = true
  tags = merge(
    {
      Name = "jenkins_eip_${count.index + 1}"
      Type = "EIP"
    },
    var.tags
  )
  depends_on = [aws_internet_gateway.jenkins_igw]
}
