resource "aws_lb" "alb" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Environment = "wordpress-alb"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "wordpress-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200,301,302,404"
    interval            = 10
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = {
    Environment = "wordpress-alb-tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "alb_target_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = var.ec2_instance_id
  port             = 80
}