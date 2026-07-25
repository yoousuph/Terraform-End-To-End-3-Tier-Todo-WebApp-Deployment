// INTERNET GATEWAY
# Create an internet gateway and associate it with the VPC
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = var.igw_name
  }
}

// NAT GATEWAY
# Create an Elastic IP address
resource "aws_eip" "nat_gw_eip" {
  domain = var.nat_gw_domain

  tags = {
    Name = var.nat_eip_name
  }
}

# Create a NAT gateway and associate it with an Elastic IP and a public subnet
resource "aws_nat_gateway" "vpc_ngw" {
  allocation_id = aws_eip.nat_gw_eip.id        # Associate the NAT gateway with the Elastic IP
  subnet_id     = aws_subnet.public_subnet1.id # Associate the NAT gateway with a public subnet

  depends_on = [aws_internet_gateway.vpc_igw] # Make sure the internet gateway is created before creating the NAT gateway

  tags = {
    Name = var.nat_gw_name
  }
}


