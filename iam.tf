// Create an IAM role for the app tier instances
resource "aws_iam_role" "ec2_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

// Attach AWS managed policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_readonly_managed_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

// Create an instance profile for the IAM role
resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.ec2_role.name
}