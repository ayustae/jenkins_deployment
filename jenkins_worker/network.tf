# Get the VPC
data "aws_vpc" "jenkins_vpc" {
  id = var.vpc_id
}

# Get the list of public subnets
data "aws_subnet" "public_subnets" {
  vpc_id    = aws_vpc.jenkins_vpc.id
  tags      = {
    Scope = "Public"
  }
}

# Get the list of private subnets
data "aws_subnet" "private_subnets" {
  vpc_id    = aws_vpc.jenkins_vpc.id
  tags      = {
    Scope = "Private"
  }
}
