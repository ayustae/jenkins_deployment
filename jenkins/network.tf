# Create a custom VPC for jenkins
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = join("/", [join(".", [var.network_ip, "0", "0"]), "16"])
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    {
      Name = "jenkins_vpc"
      Type = "VPC"
    },
    var.tags
  )
}

# Create an Internet Gateway in the VPC
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = merge(
    {
      Name = "jenkins_igw"
      Type = "IGW"
    },
    var.tags
  )
}

# Get the available availability zones
data "aws_availability_zones" "azs_total" {
  state = "available"
}

# Get 3 random availability zones
resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.azs_total.names
  result_count = 3
}

# Create three public subnets in different availability zones
resource "aws_subnet" "public_subnets" {
  count                   = 3
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.jenkins_vpc.id
  availability_zone       = random_shuffle.azs.result[count.index]
  cidr_block              = join("/", [join(".", [var.network_ip, 10 + count.index, "0"]), "24"])
  tags = merge(
    {
      Name  = "jenkins_public_subnet_${count.index + 1}"
      Type  = "Subnet"
      Scope = "Public"
      AZ    = random_shuffle.azs.result[count.index]
    },
    var.tags
  )
}

# Create three private subnets in different availability zones
resource "aws_subnet" "private_subnets" {
  count             = 3
  vpc_id            = aws_vpc.jenkins_vpc.id
  availability_zone = random_shuffle.azs.result[count.index]
  cidr_block        = join("/", [join(".", [var.network_ip, 20 + count.index, "0"]), "24"])
  tags = merge(
    {
      Name  = "jenkins_private_subnet_${count.index + 1}"
      Type  = "Subnet"
      Scope = "Private"
      AZ    = random_shuffle.azs.result[count.index]
    },
    var.tags
  )
}

# Create NAT Gateways in the public subnets
resource "aws_nat_gateway" "nat_gws" {
  count         = 3
  allocation_id = element(aws_eip.nat_ips.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  tags = merge(
    {
      Name = "jenkins_nat_gateway_${count.index + 1}"
      Type = "NAT GW"
      AZ   = random_shuffle.azs.result[count.index]
    },
    var.tags
  )
}

# Public subnets route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
  tags = merge(
    {
      Name = "jenkins_public_route_table"
      Type = "Route Table"
    },
    var.tags
  )
  depends_on = [aws_internet_gateway.jenkins_igw]
}

# Public route table association
resource "aws_route_table_association" "public_route_assoc" {
  count          = 3
  route_table_id = aws_route_table.public_route.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}

# Private subnets route table
resource "aws_route_table" "private_routes" {
  count  = 3
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gws.*.id, count.index)
  }
  tags = merge(
    {
      Name = "jenkins_private_route_table_${count.index + 1}"
      Type = "Route Table"
      AZ   = random_shuffle.azs.result[count.index]
    },
    var.tags
  )
  depends_on = [aws_internet_gateway.jenkins_igw]
}

# Private routes association
resource "aws_route_table_association" "private_routes_assoc" {
  count          = 3
  route_table_id = element(aws_route_table.private_routes.*.id, count.index)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
}
