variable "port" {
  type = number
}

variable "default_vpc_id" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

resource "aws_alb" "alb" {
  security_groups = [aws_security_group.security_group.id]
  subnets         = var.vpc_subnet_ids
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.default_vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = var.port
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 8
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "alb_zone_id" {
  value = aws_alb.alb.zone_id
}
