# Create first public subnet in the VPC
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.public_sub1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = var.pub_sub_map_public_ip_on_launch

  tags = {
    Name = var.public_sub1_name
  }
}

# Create second public subnet in the VPC
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.public_sub2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = var.pub_sub_map_public_ip_on_launch

  tags = {
    Name = var.public_sub2_name
  }
}

# Create first private subnet in the VPC
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.private_sub1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = var.priv_sub_map_public_ip_on_launch

  tags = {
    Name = var.private_sub1_name
  }
}

# Create second private subnet in the VPC
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.private_sub2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = var.priv_sub_map_public_ip_on_launch

  tags = {
    Name = var.private_sub2_name
  }
}

# Create third private subnet in the VPC
resource "aws_subnet" "private_subnet3" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.private_sub3_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = var.priv_sub_map_public_ip_on_launch

  tags = {
    Name = var.private_sub3_name
  }
}

# Create fourth private subnet in the VPC
resource "aws_subnet" "private_subnet4" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = var.private_sub4_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = var.priv_sub_map_public_ip_on_launch

  tags = {
    Name = var.private_sub4_name
  }
}