# Create Launch Configuration
resource "aws_launch_configuration" "example" {
  name          = "example-launch-config"
  image_id      = "ami-008fe2fc65df48dac"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type

  # Optionally, you can specify other parameters like security groups, user data, etc.
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name                 = "example-asg"
  launch_configuration = aws_launch_configuration.example.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2     # You can adjust this as per your initial requirement
  health_check_type    = "EC2" # Change to "ELB" if using Elastic Load Balancer health checks

  # Optionally, you can specify other parameters like VPC zone identifier, tags, etc.
  vpc_zone_identifier  = ["subnet-0d865f5201151128d"]  # Replace with your desired subnet(s)

  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
}

# Create CloudWatch Metric Alarm for Scale Out
resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "LoadAverage"  # Adjust this metric name as per your actual metric
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 50  # Adjust the threshold as needed
  alarm_description   = "Scale out when load average exceeds 50%"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# Create Auto Scaling Policy for Scale Out
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300  # 5 minutes
  autoscaling_group_name = aws_autoscaling_group.example.name
}

# Create CloudWatch Metric Alarm for Scale In
resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "LoadAverage"  # Adjust this metric name as per your actual metric
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 75  # Adjust the threshold as needed
  alarm_description   = "Scale in when load average drops below 75%"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

# Create Auto Scaling Policy for Scale In
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300  # 5 minutes
  autoscaling_group_name = aws_autoscaling_group.example.name
}
resource "aws_cloudwatch_event_rule" "daily_refresh_rule" {
  name                = "daily-refresh-rule"
  schedule_expression = "cron(0 0 * * ? *)"  # Run daily at 12 AM UTC
}

