#!/bin/bash

set -euxo pipefail

# Log all output
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1
echo "========== App Tier Setup Started =========="

# Update packages
dnf update -y

# install nodejs and mysql
dnf install -y nodejs mariadb105

echo "Waiting for RDS..."

until mysqladmin \
-h "${rds_address}" \
-P "${rds_port}" \
-u "${db_username}" \
-p"${db_password}" \
ping --silent
do
    echo "RDS not ready..."
    sleep 10
done

echo "RDS is ready."

echo "Downloading SQL..."

aws s3 cp s3://${s3_bucket_name}/sql/init.sql /tmp/init.sql

mysql \
-h "${rds_address}" \
-P "${rds_port}" \
-u "${db_username}" \
-p"${db_password}" \
< /tmp/init.sql

echo "Database configured."

# Create application directory
mkdir -p /home/ec2-user/app

# Download backend files
aws s3 cp s3://terraform-todo-app-files/app/ /home/ec2-user/app/ --recursive

# Set ownership
chown -R ec2-user:ec2-user /home/ec2-user/app

# Install application
cd /home/ec2-user/app
npm install

# Install PM2
npm install -g pm2

# Start application
su - ec2-user -c "
cd /home/ec2-user/app
pm2 start index.js --name my-api
pm2 save
"

echo "========== App Tier Setup Complete =========="
