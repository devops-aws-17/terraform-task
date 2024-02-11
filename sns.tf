resource "aws_sns_topic" "auto_scaling_alert_topic" {
  name = "auto-scaling-alert-topic"
}
resource "aws_cloudwatch_event_rule" "auto_scaling_event_rule" {
  name                = "auto-scaling-event-rule"
  event_pattern       = <<PATTERN
{
  "source": ["aws.autoscaling"],
  "detail-type": ["EC2 Instance-launch Lifecycle Action"],
  "detail": {
    "AutoScalingGroupName": ["${aws_autoscaling_group.example.name}"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "auto_scaling_alert_target" {
  rule      = aws_cloudwatch_event_rule.auto_scaling_event_rule.name
  target_id = "auto-scaling-alert-target"
  arn       = aws_sns_topic.auto_scaling_alert_topic.arn
}
resource "aws_sns_topic" "refresh_alert_topic" {
  name = "refresh-alert-topic"
}
resource "aws_cloudwatch_event_rule" "refresh_event_rule" {
  name                = "refresh-event-rule"
  schedule_expression = "cron(0 0 * * ? *)"  # Run daily at 12 AM UTC
}

resource "aws_cloudwatch_event_target" "refresh_alert_target" {
  rule      = aws_cloudwatch_event_rule.refresh_event_rule.name
  target_id = "refresh-alert-target"
  arn       = aws_sns_topic.refresh_alert_topic.arn
}
resource "aws_sns_topic_subscription" "auto_scaling_alert_subscription" {
  topic_arn = aws_sns_topic.auto_scaling_alert_topic.arn
  protocol  = "email"
  endpoint  = "coolprasad1432@gmail.com"  # Replace with your email address
}

resource "aws_sns_topic_subscription" "refresh_alert_subscription" {
  topic_arn = aws_sns_topic.refresh_alert_topic.arn
  protocol  = "email"
  endpoint  = "coolprasad1432@gmail.com"  # Replace with your email address
}

