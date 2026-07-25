// PUBLIC ALB
# Create a target group for the public load balancer
resource "aws_lb_target_group" "pub_sub_alb_tg" {
  name     = var.pub_target_group_name
  port     = var.http_port
  protocol = var.http_protocol
  vpc_id   = aws_vpc.three_tier_vpc.id

  # Set the health check configuration for the target group
  health_check {
    path     = var.root_path
    port     = var.http_port
    protocol = var.http_protocol
    interval = var.hc_interval
    timeout  = var.hc_timeout
    matcher  = var.matcher
  }
}

# Create public ALB
resource "aws_lb" "pub_sub_alb" {
  name = var.pub_load_balancer_name
  subnets = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]

  security_groups = [aws_security_group.pub_sub_alb_sg.id]

  depends_on = [aws_lb_target_group.pub_sub_alb_tg]

  tags = {
    Name = var.pub_load_balancer_name
  }

}

resource "aws_lb_listener" "pub_sub_alb_listener" {
  load_balancer_arn = aws_lb.pub_sub_alb.arn
  port              = var.http_port
  protocol          = var.http_protocol

  # Set the default action for the listener
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}


# Create public ALB listener rule
resource "aws_lb_listener_rule" "pub_sub_alb_listener_allow_cloudfront" {
  listener_arn = aws_lb_listener.pub_sub_alb_listener.arn
  priority     = 100

  action {
    type             = var.alb_listener_default_action
    target_group_arn = aws_lb_target_group.pub_sub_alb_tg.arn
  }

  condition {
    http_header {
      http_header_name = "X-Origin-Verify"

      values = [
        "my-super-secret-key"
      ]
    }
  }
}



// PRIVATE ALB
# Create a target group for the load balancer
resource "aws_lb_target_group" "priv_sub_alb_tg" {
  name     = var.priv_target_group_name
  port     = var.cust_http_port
  protocol = var.http_protocol
  vpc_id   = aws_vpc.three_tier_vpc.id

  # Set the health check configuration for the target group
  health_check {
    path     = var.health_path
    port     = var.cust_http_port
    protocol = var.http_protocol
    interval = var.hc_interval
    timeout  = var.hc_timeout
    matcher  = var.matcher
  }
}

# Create private ALB
resource "aws_lb" "priv_sub_alb" {
  name = var.priv_load_balancer_name
  subnets = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

  internal = true

  security_groups = [aws_security_group.priv_sub_alb_sg.id]

  depends_on = [aws_lb_target_group.priv_sub_alb_tg]

  tags = {
    Name = var.priv_load_balancer_name
  }

}

# Create ALB listener
resource "aws_lb_listener" "priv_sub_alb_listener" {
  load_balancer_arn = aws_lb.priv_sub_alb.arn
  port              = var.http_port
  protocol          = var.http_protocol

  # Set the default action for the listener
  default_action {
    type             = var.alb_listener_default_action
    target_group_arn = aws_lb_target_group.priv_sub_alb_tg.arn
  }
}