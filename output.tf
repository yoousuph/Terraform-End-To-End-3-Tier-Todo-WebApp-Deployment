# Output
output "three_tier_vpc-id" {
  value = aws_vpc.three_tier_vpc.id
}

output "public_subnet1_id" {
  value = aws_subnet.public_subnet1.id
}

output "public_subnet2_id" {
  value = aws_subnet.public_subnet2.id
}

output "private_subnet1_id" {
  value = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
  value = aws_subnet.private_subnet2.id
}

output "private_subnet3_id" {
  value = aws_subnet.private_subnet3.id
}

output "private_subnet4_id" {
  value = aws_subnet.private_subnet4.id
}

output "vpc_igw_id" {
  value = aws_internet_gateway.vpc_igw.id
}

output "pub-alb-dns-name" {
  value = aws_lb.pub_sub_alb.dns_name
}

output "priv-alb-dns-name" {
  value = aws_lb.priv_sub_alb.dns_name
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.todo_cf.domain_name
}