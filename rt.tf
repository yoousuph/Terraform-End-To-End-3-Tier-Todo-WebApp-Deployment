// PUBLIC ROUTE TABLE
# Creates a public route table with a default route to the internet gateway
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  # Create a default route for the internet gateway with destination 0.0.0.0/0
  route {
    cidr_block = var.public_rt_cidr
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}

# Associates the public route table with the public subnet 1
resource "aws_route_table_association" "pub_sub1_rt_ass" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.pub_rt.id

  # Wait for the public route table to be created before creating this association
  depends_on = [aws_route_table.pub_rt]
}

# Associates the public route table with the public subnet 2
resource "aws_route_table_association" "pub_sub2_rt_ass" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.pub_rt.id

  # Wait for the public route table to be created before creating this association
  depends_on = [aws_route_table.pub_rt]
}

// PRIVATE ROUTE TABLE
# Creates a private route table with a default route to the NAT gateway
resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  # Create a default route for the NAT gateway with destination 0.0.0.0/0
  route {
    cidr_block = var.private_rt_cidr
    gateway_id = aws_nat_gateway.vpc_ngw.id
  }

  tags = {
    Name = var.private_rt_name
  }
}

# Associates the private route table with the private subnet 1
resource "aws_route_table_association" "priv_sub1_rt_ass" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.priv_rt.id

  # Wait for the private route table to be created before creating this association
  depends_on = [aws_route_table.priv_rt]
}

# Associates the private route table with the private subnet 2
resource "aws_route_table_association" "priv_sub2_rt_ass" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.priv_rt.id

  # Wait for the private route table to be created before creating this association
  depends_on = [aws_route_table.priv_rt]
}
# Associates the private route table with the private subnet 3
resource "aws_route_table_association" "priv_sub3_rt_ass" {
  subnet_id      = aws_subnet.private_subnet3.id
  route_table_id = aws_route_table.priv_rt.id

  # Wait for the private route table to be created before creating this association
  depends_on = [aws_route_table.priv_rt]
}
# Associates the private route table with the private subnet 4
resource "aws_route_table_association" "priv_sub4_rt_ass" {
  subnet_id      = aws_subnet.private_subnet4.id
  route_table_id = aws_route_table.priv_rt.id

  # Wait for the private route table to be created before creating this association
  depends_on = [aws_route_table.priv_rt]
}


