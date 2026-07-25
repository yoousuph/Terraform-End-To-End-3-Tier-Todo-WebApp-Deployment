# locals for internal ALB dns name to be refernced in nginx file
locals {
  nginx_conf = templatefile("${path.module}/webapp/nginx.conf.tpl", {
    internal_alb_dns = aws_lb.priv_sub_alb.dns_name
  })
}

# locals for database login credentials
locals {
  app_user_data = templatefile("${path.module}/app_ud.sh.tpl", {
    rds_address    = aws_db_instance.db_instance.address
    rds_port       = aws_db_instance.db_instance.port
    db_username    = aws_db_instance.db_instance.username
    db_password    = aws_db_instance.db_instance.password
    db_name        = aws_db_instance.db_instance.db_name
    s3_bucket_name = aws_s3_bucket.s3_todo_app_bucket.bucket
  })
}

locals {
  index_file = templatefile("${path.module}/webapp/app/index.js.tpl", {
    rds_address = aws_db_instance.db_instance.address
    rds_port    = aws_db_instance.db_instance.port
    db_username = aws_db_instance.db_instance.username
    db_password = aws_db_instance.db_instance.password
    db_name     = aws_db_instance.db_instance.db_name
  })
}

locals {
  sql_init = templatefile("${path.module}/sql/init.sql.tpl", {
    db_name = aws_db_instance.db_instance.db_name
  })
}