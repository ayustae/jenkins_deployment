# Load balancer security group
resource "aws_security_group" "lb-sg" {
  name        = "loadbalancer-sg"
  description = "Allow TCP/443 and TCP/80"
  vpc_id      = aws_vpc.jenkins_vpc.id
  ingress {
    description = "Allow TCP/443 from anywhere"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow TCP/80 from anywhere"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow everything to anywhere"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Jenkins master security group
resource "aws_security_group" "jenkins_master-sg" {
  name        = "jenkins-master-sg"
  description = "Allow TCP/8080 and ICMP"
  vpc_id      = aws_vpc.jenkins_vpc.id
  ingress {
    description     = "Allow TCP/8080 from the LB"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.lb-sg.id]
  }
  egress {
    description = "Allow everything to anywhere"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Jenkins worker security group
resource "aws_security_group" "jenkins_worker-sg" {
  name        = "jenkins-worker-sg"
  description = "Allow ICMP and connections in the same SG"
  vpc_id      = aws_vpc.jenkins_vpc.id
  ingress {
    description     = "Allow anything from the Master SG"
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.jenkins_master-sg.id]
    self            = true
  }
  ingress {
    description = "Allow ICMP from anywhere"
    protocol    = "icmp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow everything to anywhere"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
