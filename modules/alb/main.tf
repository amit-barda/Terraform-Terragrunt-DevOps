# Internet-facing ALB in public subnets. A single HTTP listener defaults to
# a 404 fixed response; host-header rules forward matching traffic to
# per-service target groups (health-checked on the given path).

locals {
  routing_rules_by_name = {
    for idx, rule in var.routing_rules : rule.name => merge(rule, { priority = idx + 1 })
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Internet-facing ALB for ${var.name_prefix}: allows inbound HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound (to reach targets in private subnets)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_lb" "this" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "this" {
  for_each = local.routing_rules_by_name

  name        = "${var.name_prefix}-${each.value.name}-tg"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Fargate tasks don't have an EC2 instance ID to register

  health_check {
    path                = each.value.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.name_prefix}-${each.value.name}-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "host_based" {
  for_each = local.routing_rules_by_name

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  condition {
    host_header {
      values = [each.value.host_header]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}
