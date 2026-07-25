resource "aws_key_pair" "three_tier_pub_key" {
  key_name   = var.three_tier_pub_key
  public_key = file("C:/Users/Administrator/.ssh/id_rsa.pub")
}

# resource "aws_key_pair" "three_tier_pub_key" {
#   key_name   = var.three_tier_pub_key
#   public_key = file("C:/Users/REALITY/.ssh/id_rsa.pub")
# }


