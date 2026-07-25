resource "aws_security_group" "db_sg" {
  name        = var.db_sg_name
  description = var.db_sg_name
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = var.tcp_protocol
    security_groups = [aws_security_group.priv_sub_asg_lt_sg.id]
  }

  egress {
    from_port   = var.any_port
    to_port     = var.any_port
    protocol    = var.any_protocol
    cidr_blocks = var.db_egress_cidr
  }
}

