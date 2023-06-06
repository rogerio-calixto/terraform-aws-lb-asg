resource "aws_alb" "load_balancer" {
  name                       = "${var.project}-lb"
  security_groups            = ["${aws_security_group.sg-lb.id}"]
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = false
  subnets = module.network.public-subnet-ids

  depends_on = [
    aws_security_group.sg-lb
  ]
}

resource "aws_alb_target_group" "tg-load_balancer" {
  name        = "${var.project}-tg-lb"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = module.network.vpc-id

  health_check {
    healthy_threshold = 2
    path              = "/"
    matcher           = "200"
  }

  stickiness {
    cookie_duration = 3600
    enabled         = true
    type            = "lb_cookie"
  }
}

resource "aws_alb_listener" "listener-load_balancer" {
  default_action {
    target_group_arn = aws_alb_target_group.tg-load_balancer.arn
    type             = "forward"
  }

  load_balancer_arn = aws_alb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  depends_on = [aws_alb_target_group.tg-load_balancer]
}