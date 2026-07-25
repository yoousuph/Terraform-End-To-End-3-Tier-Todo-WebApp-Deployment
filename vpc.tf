# Create an AWS VPC
resource "aws_vpc" "three_tier_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.instance_tenancy

  tags = {
    Name = var.vpc_name
  }
}