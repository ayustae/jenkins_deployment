# Scale Up CPU alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  alarm_description   = "Alarm on high CPU usage"
  comparison_operator = "GreaterThanOrEqualThreshold"
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
  comparison_operator = "GreaterThanOrEqualThreshold"
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
