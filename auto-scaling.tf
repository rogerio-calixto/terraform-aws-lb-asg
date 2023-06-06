resource "aws_launch_configuration" "lc" {
  image_id      = var.ami
  instance_type = var.instance-type
  security_groups = [aws_security_group.sg.id]
  key_name = var.keypair-name
  associate_public_ip_address = true

  # EBS root
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_security_group.sg]
}

resource "aws_autoscaling_group" "scalegroup" {
  name                 = "${var.project}-sg"
  launch_configuration = aws_launch_configuration.lc.name
  vpc_zone_identifier  = var.public-subnet_ids
  min_size             = 0
  max_size             = 2
  desired_capacity          = 0
  force_delete              = true
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_alb_target_group.tg-load_balancer.arn]

  lifecycle {
    create_before_destroy = true
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${var.project}-sg"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_configuration.lc]
}


resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.scalegroup.id
  lb_target_group_arn    = aws_alb_target_group.tg-load_balancer.arn

  depends_on = [
    aws_autoscaling_group.scalegroup,
    aws_alb_target_group.tg-load_balancer
  ]
}

# resource "aws_autoscaling_policy" "autopolicy" {
#   name                   = "terraform-autoplicy-up"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.scalegroup.name
# }

# resource "aws_cloudwatch_metric_alarm" "cpualarm" {
#   alarm_name          = "terraform-alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "90"

#   alarm_description = "This metric monitor EC2 instance cpu utilization"
#   alarm_actions     = ["${aws_autoscaling_policy.autopolicy.arn}"]
# }

# #
# resource "aws_autoscaling_policy" "autopolicy-down" {
#   name                   = "terraform-autoplicy-down"
#   scaling_adjustment     = -1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.scalegroup.name
# }

# resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
#   alarm_name          = "terraform-alarm-down"
#   comparison_operator = "LessThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "40"

#   alarm_description = "This metric monitor EC2 instance cpu utilization"
#   alarm_actions     = ["${aws_autoscaling_policy.autopolicy-down.arn}"]
# }
