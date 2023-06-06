resource "aws_iam_role" "ec2_acess_s3_role" {
  name = "${local.project}-EC2-Acesso-S3-Role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "${local.project}-ec2_profile"
  role = aws_iam_role.ec2_acess_s3_role.name
}

data "template_file" "user_data" {
  template = file("scripts/start_instance.sh")
  vars = {
    project = local.project
  }
}

# aws_launch_configuration will be deprecated
# Soon I will migrate to launch templates
resource "aws_launch_configuration" "lc" {
  image_id                    = var.ami
  instance_type               = var.instance-type
  security_groups             = [aws_security_group.sg.id]
  key_name                    = var.keypair-name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile.name
  user_data                   = data.template_file.user_data.rendered

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
  name                      = "${local.project}"
  launch_configuration      = aws_launch_configuration.lc.name
  vpc_zone_identifier       = module.network.public-subnet-ids
  min_size                  = var.asg-min
  max_size                  = var.subnet_counts
  desired_capacity          = var.subnet_counts
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
    value               = "${var.instance-name}"
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
