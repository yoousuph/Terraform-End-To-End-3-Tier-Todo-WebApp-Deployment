#!/bin/bash

set -euo pipefail

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

echo "========== Web Tier Setup Started =========="

echo "[1] Running as user:"
whoami

echo "[2] Updating system..."
dnf update -y
echo "✓ System updated"

echo "[3] Installing Nginx and AWS CLI..."
dnf install -y nginx awscli
echo "✓ Nginx and AWS CLI installed"

echo "[4] Enabling Nginx..."
systemctl enable nginx
systemctl start nginx
systemctl status nginx --no-pager
echo "✓ Nginx started"

echo "[5] Installing Node.js..."
dnf install -y nodejs
echo "✓ Node.js installed"

echo "[6] Node version:"
node -v

echo "[7] npm version:"
npm -v

echo "[8] Waiting for IAM role credentials..."

until aws sts get-caller-identity >/dev/null 2>&1
do
    echo "IAM role not ready yet..."
    sleep 5
done

echo "✓ IAM credentials available"

echo "[9] Creating application directory..."
mkdir -p /home/ec2-user/web
echo "✓ Directory created"

echo "[10] Downloading React application..."
aws s3 cp s3://terraform-todo-app-files/web/ /home/ec2-user/web/ --recursive
echo "✓ React files downloaded"

echo "[11] Listing downloaded files..."
ls -lah /home/ec2-user/web

echo "[12] Changing directory..."
cd /home/ec2-user/web
pwd

echo "[13] Installing npm packages..."
npm install
echo "✓ npm install complete"

echo "[14] Building React app..."
npm run build
echo "✓ React build complete"

echo "[15] Listing dist directory..."
ls -lah dist

echo "[16] Removing default nginx files..."
rm -rf /usr/share/nginx/html/*
echo "✓ Default files removed"

echo "[17] Copying React dist files..."
cp -r dist/* /usr/share/nginx/html/
echo "✓ React copied"

echo "[18] Downloading nginx.conf from S3..."
aws s3 cp s3://terraform-todo-app-files/nginx.conf /etc/nginx/nginx.conf
echo "✓ nginx.conf downloaded"

echo "[19] Checking nginx configuration..."
nginx -t
echo "✓ nginx configuration is valid"

echo "[20] Restarting nginx..."
systemctl restart nginx
echo "✓ nginx restarted"

echo "[21] Nginx status..."
systemctl status nginx --no-pager

echo "========== Web Tier Setup Complete =========="