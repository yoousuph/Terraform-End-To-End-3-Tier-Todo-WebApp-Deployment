// PUBLIC SUBNET AUTOSCALING GROUP
# Create a launch template with the specified configurations
resource "aws_launch_template" "pub_sub_asg_lt" {
  name                   = var.pub_sub_asg_lt_name
  image_id               = var.pub_sub_asg_lt_ami
  instance_type          = var.pub_sub_asg_lt_instance_type
  key_name               = aws_key_pair.three_tier_pub_key.key_name
  vpc_security_group_ids = [aws_security_group.pub_sub_asg_lt_sg.id]
  user_data              = filebase64("${path.root}/web_ud.sh")

  iam_instance_profile { // not requiered as we are using the default instance profile for the public subnet instances
    name = aws_iam_instance_profile.ec2_iam_instance_profile.name
  }

  depends_on = [
    aws_s3_object.nginx_file
  ]
}

# Create an autoscaling group with the specified configurations
resource "aws_autoscaling_group" "pub_sub_asg" {
  name             = var.pub_sub_asg_name
  min_size         = var.pub_sub_asg_min
  max_size         = var.pub_sub_asg_max
  desired_capacity = var.pub_sub_asg_des_cap
  vpc_zone_identifier = [
    aws_subnet.public_subnet1.id,
    aws_subnet.public_subnet2.id
  ]

  launch_template {
    id = aws_launch_template.pub_sub_asg_lt.id
  }

  # Tag the autoscaling group for easier identification
  tag {
    key                 = "Name"
    value               = "Public Sub ASG"
    propagate_at_launch = true
  }
}

# Attach the autoscaling group to the target group of the ALB
resource "aws_autoscaling_attachment" "pub_sub_asg_tg_attach" {
  autoscaling_group_name = aws_autoscaling_group.pub_sub_asg.id
  lb_target_group_arn    = aws_lb_target_group.pub_sub_alb_tg.arn
}


// PRIVATE SUBNET AUTOSCALING GROUP
# Create a launch template with the specified configurations
resource "aws_launch_template" "priv_sub_asg_lt" {
  name                   = var.priv_sub_asg_lt_name
  image_id               = var.priv_sub_asg_lt_ami
  instance_type          = var.priv_sub_asg_lt_instance_type
  key_name               = aws_key_pair.three_tier_pub_key.key_name
  vpc_security_group_ids = [aws_security_group.priv_sub_asg_lt_sg.id]
  user_data              = base64encode(local.app_user_data)

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_iam_instance_profile.name
  }

}

# Create an autoscaling group with the specified configurations
resource "aws_autoscaling_group" "priv_sub_asg" {
  name             = var.priv_sub_asg_name
  min_size         = var.priv_sub_asg_min
  max_size         = var.priv_sub_asg_max
  desired_capacity = var.priv_sub_asg_des_cap
  vpc_zone_identifier = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id
  ]

  launch_template {
    id = aws_launch_template.priv_sub_asg_lt.id
  }

  # Tag the autoscaling group for easier identification
  tag {
    key                 = "Name"
    value               = "Private Sub ASG"
    propagate_at_launch = true
  }
}

# Attach the autoscaling group to the target group of the ALB
resource "aws_autoscaling_attachment" "priv_sub_asg_tg_attach" {
  autoscaling_group_name = aws_autoscaling_group.priv_sub_asg.id
  lb_target_group_arn    = aws_lb_target_group.priv_sub_alb_tg.arn
}


