resource "aws_security_group" "sg-lb" {
  name        = "${local.project}-sg_lb"
  vpc_id      = module.network.vpc-id
  description = "Libera entrada"

  ingress {
    description = "Porta HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project}-sg_lb"
  }
}

resource "aws_security_group" "sg" {
  name        = "${local.project}-sg"
  vpc_id      = module.network.vpc-id
  description = "Libera entrada para LB"

  ingress {
    description     = "Porta HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg-lb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project}-sg"
  }
}