resource "aws_db_instance" "db_instance" {
  identifier             = var.db_instance_identifier
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  storage_encrypted      = var.db_storage_encrypted
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = var.db_port
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true

  depends_on = [aws_db_subnet_group.db_subnet_group]

  tags = {
    Name = var.db_instance_identifier
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = var.db_subnet_group_name
  subnet_ids = [
    aws_subnet.private_subnet3.id,
    aws_subnet.private_subnet4.id
  ]

  tags = {
    Name = var.db_subnet_group_name
  }
}

