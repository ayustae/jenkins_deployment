# Master instance autorecovery alarms
resource "aws_cloudwatch_metric_alarm" "jenkins_master_autorecovery" {
  alarm_name          = "jenkins_master-autorecovery"
  alarm_description   = "Monitor status checks of the Jenkins master"
  alarm_actions       = ["arn:aws:automate:${var.region}:ec2:recover"]
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  period              = "60"
  evaluation_periods  = "2"
  dimensions = {
    InstanceId = aws_instance.jenkins_master.id
  }
}
