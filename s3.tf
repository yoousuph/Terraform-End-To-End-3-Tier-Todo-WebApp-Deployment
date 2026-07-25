// Create S3 bucket
resource "aws_s3_bucket" "s3_todo_app_bucket" {
  bucket = var.s3_bucket_name
}

// Sync web files from the local directory to the S3 bucket
resource "aws_s3_object" "web_files" {
  for_each = fileset("${path.module}/webapp/web", "**")
  bucket   = aws_s3_bucket.s3_todo_app_bucket.id
  key      = "web/${each.value}"
  source   = "${path.module}/webapp/web/${each.value}"
  etag     = filemd5("${path.module}/webapp/web/${each.value}")
}

// exclude index.js.tpl and init.sql.tpl  first
locals {
  app_files = {
    for f in fileset("${path.module}/webapp/app", "**") :
    f => f
    if f != "index.js.tpl"
  }
}

// then upload all files in the ap folder
resource "aws_s3_object" "app_files" {
  for_each = local.app_files
  bucket   = aws_s3_bucket.s3_todo_app_bucket.id
  key      = "app/${each.value}"
  source   = "${path.module}/webapp/app/${each.value}"
  etag     = filemd5("${path.module}/webapp/app/${each.value}")
}

// Copy nginx file from the local directory to the S3 bucket
resource "aws_s3_object" "nginx_file" {
  bucket       = aws_s3_bucket.s3_todo_app_bucket.id
  key          = "nginx.conf"
  content      = local.nginx_conf
  content_type = "text/plain"
}

resource "aws_s3_object" "app_index_file" {
  bucket       = aws_s3_bucket.s3_todo_app_bucket.id
  key          = "app/index.js"
  content      = local.index_file
  content_type = "application/javascript"
}

resource "aws_s3_object" "sql_init_file" {
  bucket  = aws_s3_bucket.s3_todo_app_bucket.id
  key     = "sql/init.sql"
  content = local.sql_init
}