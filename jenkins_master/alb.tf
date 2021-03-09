# Create an Application Load Balancer
resource "aws_lb" "jenkins_lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]
  tags               = {
    Name = "jenkins_alb"
    Type = "ALB"
    for tag in var.tags: tak.key => tag.value
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "jenkins_lb_master_target_group" {
  name        = "jenkins-lb-master-group"
  port        = var.webserver_port
  target_type = "instance"
  vpc_id      = aws_vpc.jenkins_vpc.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = var.webserver_port
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags               = {
    Name = "jenkins_master_target_group"
    Type = "Target Group"
    for tag in var.tags: tak.key => tag.value
  }
}

# Create a listener for the ALB for HTTP
resource "aws_lb_listener" "jenkins-listener-http" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create a listener for the ALB for HTTPS
resource "aws_lb_listener" "jenkins-listener-https" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins_https_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_lb_master_target_group.arn
  }
}

# Attach the master node to the Load Balancer
resource "aws_lb_target_group_attachment" "jenkins_master_attachment" {
  target_group_arn = aws_lb_target_group.jenkins_lb_master_target_group.arn
  target_id        = aws_instance.jenkins_master.id
  port             = var.webserver_port
}
