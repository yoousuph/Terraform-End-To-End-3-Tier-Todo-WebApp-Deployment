// PUBLIC SUBNETS ALB SECURITY GROUP
# Create security group for public ALB
resource "aws_security_group" "pub_sub_alb_sg" {

  # Set name and description of the security group
  name        = var.pub_sub_alb_sg_name
  description = var.pub_sub_alb_sg_name

  # Set the VPC ID where the security group will be created
  vpc_id     = aws_vpc.three_tier_vpc.id
  depends_on = [aws_vpc.three_tier_vpc] # Ensure the VPC is created before creating the security group

  # Inbound Rule
  # HTTP access from anywhere
  ingress {
    description = var.http_port
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp_protocol
    cidr_blocks = var.pub_sub_alb_sg_ingress_cidr_blocks
  }

  # Outbound Rule
  # Allow all egress traffic
  egress {
    from_port   = var.any_port
    to_port     = var.any_port
    protocol    = var.any_protocol
    cidr_blocks = var.pub_sub_alb_sg_egress_cidr_blocks
  }

  # Set tags for the security group
  tags = {
    Name = var.pub_sub_alb_sg_name
  }
}


// PRIVATE SUBNETS ALB SECURITY GROUP
# Create security group for private ALB
resource "aws_security_group" "priv_sub_alb_sg" {

  # Set name and description of the security group
  name        = var.priv_sub_alb_sg_name
  description = var.priv_sub_alb_sg_name

  # Set the VPC ID where the security group will be created
  vpc_id     = aws_vpc.three_tier_vpc.id
  depends_on = [aws_vpc.three_tier_vpc] # Ensure the VPC is created before creating the security group

  # Inbound Rule
  # HTTP access from anywhere
  ingress {
    description     = var.http_port
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = var.tcp_protocol
    security_groups = [aws_security_group.pub_sub_asg_lt_sg.id]
  }

  # Outbound Rule
  # Allow all egress traffic
  egress {
    from_port   = var.any_port
    to_port     = var.any_port
    protocol    = var.any_protocol
    cidr_blocks = var.priv_sub_alb_sg_egress_cidr_blocks
  }

  # Set tags for the security group
  tags = {
    Name = var.priv_sub_alb_sg_name
  }
}



