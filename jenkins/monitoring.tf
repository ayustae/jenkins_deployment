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

# Scale Up CPU alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  alarm_description   = "Alarm on high CPU usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = 60
  evaluation_periods  = 2
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  threshold           = "50"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_workers.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
}

# Scale Down CPU alarm
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "low-cpu-alarm"
  alarm_description   = "Alarm on low CPU usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = 60
  evaluation_periods  = 2
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  threshold           = "5"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.jenkins_workers.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_down.arn]
}
