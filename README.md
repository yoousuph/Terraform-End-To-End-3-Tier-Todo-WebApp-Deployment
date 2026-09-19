# 🚀 AWS Three-Tier Todo Application — Infrastructure as Code with Terraform

> A production-style three-tier web application deployed on AWS and provisioned entirely through **Terraform**, with automated infrastructure creation, Nginx configuration, deployment scripts, private application/database tiers, load balancing, and remote Terraform state stored securely in Amazon S3.

---

## 📌 Project Overview

This project demonstrates the design and automated deployment of a **three-tier Todo web application on AWS using Terraform**.

The goal was not simply to deploy a working application, but to build the underlying AWS infrastructure in a way that reflects how cloud infrastructure can be designed, automated, secured, and reproduced using **Infrastructure as Code (IaC)**.

The application was divided into three logical tiers:


![Terraform_architecture.JPEG](https://github.com/yoousuph/Terraform-End-To-End-3-Tier-Todo-WebApp-Deployment/blob/main/imgs/terraform-todo-architecture.jpg)


The architecture was designed to separate the presentation, application, and database layers while restricting direct internet access to the private components.

---

# 🎯 Project Objectives

The major objectives of this project were to:

* Design a three-tier AWS architecture.
* Provision infrastructure using Terraform.
* Avoid manually creating AWS resources through the console wherever possible.
* Build reusable Terraform configurations.
* Automate EC2 configuration using scripts.
* Configure Nginx automatically during deployment.
* Deploy the web tier behind an Application Load Balancer.
* Keep application servers in private subnets.
* Deploy the database in private database subnets.
* Implement Auto Scaling for application workloads.
* Use Amazon RDS for the database layer.
* Store Terraform state remotely in Amazon S3.
* Separate infrastructure configuration from application configuration.
* Implement security groups according to tier responsibilities.
* Troubleshoot dependencies between AWS resources and application components.
* Build infrastructure that could be recreated using Terraform.

---

# 🏗️ Architecture

## 1. Presentation / Web Tier

The web tier is responsible for serving the frontend application.

Components include:

* EC2 instances
* Auto Scaling Group
* Nginx
* Public Application Load Balancer
* CloudFront
* Public subnets

Nginx serves the frontend static files and acts as a reverse proxy for application API requests.

Example:

```nginx
location /api/ {
    proxy_pass http://internal-load-balancer;
}
```

This allows the browser to communicate with the application without exposing the backend servers directly to the internet.

---

# 2. Application Tier

The application tier contains the backend API.

Components include:

* EC2 instances
* Auto Scaling Group
* Node.js
* PM2
* Internal Application Load Balancer
* Private subnets

The backend instances are not directly accessible from the internet.

Traffic reaches the application tier through the internal load balancer.

This provides an additional layer of isolation between the public web tier and the application servers.

---

# 3. Database Tier

The database tier uses:

* Amazon RDS
* MySQL
* DB subnet group
* Private subnets

The database is isolated from the public internet.

Only the application tier is allowed to communicate with the database on the required database port.

Conceptually:

```text
Internet
   │
   ▼
Web Tier
   │
   ▼
Application Tier
   │
   ▼
Database Tier
```

Each tier has a specific responsibility and network boundary.

---

# ☁️ AWS Services Used

| Category           | AWS Service               | Purpose                                |
| ------------------ | ------------------------- | -------------------------------------- |
| Networking         | Amazon VPC                | Isolated network                       |
| Networking         | Public Subnets            | Internet-facing resources              |
| Networking         | Private Subnets           | Application resources                  |
| Networking         | DB Subnets                | Database isolation                     |
| Networking         | Internet Gateway          | Internet connectivity                  |
| Networking         | NAT Gateway               | Outbound internet from private subnets |
| Networking         | Route Tables              | Traffic routing                        |
| Compute            | Amazon EC2                | Web and application servers            |
| Compute            | Auto Scaling Groups       | Scaling and instance replacement       |
| Load Balancing     | Application Load Balancer | Traffic distribution                   |
| CDN                | CloudFront                | Content delivery                       |
| Database           | Amazon RDS MySQL          | Managed relational database            |
| Storage            | Amazon S3                 | Static files and Terraform state       |
| Security           | Security Groups           | Network-level access control           |
| IAM                | IAM Roles                 | AWS permissions for EC2                |
| IaC                | Terraform                 | Infrastructure automation              |
| Web Server         | Nginx                     | Static content and reverse proxy       |
| Process Management | PM2                       | Node.js process management             |

---

# 📁 Terraform Project Structure

The project was structured to separate infrastructure responsibilities and supporting configuration files.

```text
terraform-todo-app/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
│
├── backend.tf
│
├── vpc.tf
├── subnets.tf
├── route_tables.tf
├── nat_gateway.tf
│
├── security_groups.tf
│
├── alb.tf
├── internal-alb.tf
│
├── web.tf
├── app.tf
├── autoscaling.tf
│
├── rds.tf
│
├── cloudfront.tf
│
├── iam.tf
│
├── scripts/
│   ├── web-user-data.sh
│   ├── app-user-data.sh
│   └── database-init.sh
│
├── nginx/
│   └── nginx.conf
│
├── sql/
│   └── init.sql
│
└── README.md
```

> The exact file organization can vary depending on the final version of the project.

---

# 🔧 Infrastructure as Code with Terraform

Terraform was used as the primary infrastructure provisioning tool.

Instead of manually creating resources through the AWS Management Console, infrastructure was defined declaratively.

For example:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "todo-vpc"
  }
}
```

Terraform was then responsible for creating the required AWS resources and establishing their dependencies.

The general workflow was:

```text
Terraform Configuration
          │
          ▼
terraform init
          │
          ▼
terraform plan
          │
          ▼
terraform apply
          │
          ▼
AWS Infrastructure
```

---

# 🗄️ Remote Terraform State with Amazon S3

One of the important parts of the project was moving Terraform state away from the local machine.

Instead of relying on:

```text
terraform.tfstate
```

locally, the Terraform state was stored remotely in an Amazon S3 bucket.

Conceptually:

```text
Developer Machine
       │
       │ Terraform
       ▼
   AWS S3 Bucket
       │
       ▼
Terraform State
```

This approach provides several advantages:

* Centralized state storage
* Better protection against local state loss
* Easier collaboration
* State persistence outside the development machine
* A more realistic infrastructure workflow

The Terraform configuration included an S3 backend similar to:

```hcl
terraform {
  backend "s3" {
    bucket = "YOUR-TERRAFORM-STATE-BUCKET"
    key    = "todo-app/terraform.tfstate"
    region = "us-east-1"
  }
}
```

> Never commit AWS credentials, secrets, passwords, database credentials, or sensitive Terraform state to Git.

---

# 🌐 Nginx Configuration

Nginx was used as the web server for the frontend tier.

Rather than manually logging into every EC2 instance and configuring Nginx, an Nginx configuration file was incorporated into the deployment process.

Example:

```nginx
server {
    listen 80;

    root /var/www/html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://BACKEND_ENDPOINT;
    }
}
```

The Terraform deployment process could install and configure this file automatically on new instances.

This was particularly important because the web tier used Auto Scaling.

If a new EC2 instance was created, it needed to become fully functional without requiring manual configuration.

---

# 📜 Deployment Scripts

Shell scripts were used to bootstrap EC2 instances.

The scripts handled tasks such as:

* Installing required packages
* Installing Nginx
* Installing Node.js
* Installing PM2
* Creating application directories
* Copying configuration files
* Starting services
* Configuring the application
* Setting appropriate permissions

A simplified example:

```bash
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
```

This reduced the amount of manual configuration required after infrastructure deployment.

---

# 🔐 Security Architecture

Security was implemented using multiple layers.

## Security Groups

Different security groups were created for different tiers.

Example:

```text
Internet
   │
   ▼
Web Security Group
   │
   ▼
App Security Group
   │
   ▼
Database Security Group
```

The database security group does not need to allow arbitrary internet traffic.

Instead, access can be restricted to the application security group.

Conceptually:

```text
Web SG
  │
  │ HTTP/HTTPS
  ▼
App SG
  │
  │ MySQL
  ▼
DB SG
```

This follows the principle of allowing only the traffic required by each tier.

---

# 📈 Auto Scaling

Auto Scaling Groups were used to make the compute tiers more resilient.

Instead of depending on a single EC2 instance:

```text
          EC2
           │
         Failure
           │
       Application
          DOWN
```

the architecture allows multiple instances:

```text
             ALB
              │
       ┌──────┴──────┐
       ▼             ▼
     EC2-1         EC2-2
       │             │
       └──────┬──────┘
              │
         Application
```

If an instance becomes unhealthy, the Auto Scaling Group can replace it.

This also makes the infrastructure more suitable for handling changes in workload.

---

# ⚖️ Load Balancing

Two levels of load balancing were incorporated into the architecture.

## Public ALB

The public ALB receives traffic destined for the web tier.

```text
CloudFront
     │
     ▼
Public ALB
     │
 ┌───┴───┐
 ▼       ▼
Web 1   Web 2
```

## Internal ALB

The internal ALB handles communication between the web tier and application tier.

```text
Web Tier
    │
    ▼
Internal ALB
    │
 ┌──┴──┐
 ▼     ▼
App 1 App 2
```

This prevents the application servers from needing to be publicly accessible.

---

# 🗃️ Database Initialization

Database initialization was automated rather than relying entirely on manually entering SQL commands.

An SQL initialization script was used to create the required database structures.

For example:

```sql
CREATE DATABASE IF NOT EXISTS transactions;
```

The application tier was then configured to communicate with the RDS database.

---

# 🧩 Major Challenges Encountered

Building the project was not simply a matter of writing Terraform resources.

A significant portion of the work involved understanding how independently created AWS resources depend on one another.

The following were some of the major challenges encountered during development.

---

## 1. Managing Terraform Resource Dependencies

One of the first challenges was understanding that Terraform resources are not isolated.

For example:

```text
VPC
 │
 ├── Subnets
 │     │
 │     ├── Route Tables
 │     │
 │     └── Security Groups
 │
 ├── ALB
 │
 ├── EC2
 │
 └── RDS
```

A problem with an upstream resource could prevent several downstream resources from functioning correctly.

Terraform's dependency graph helped solve this, but understanding **implicit vs explicit dependencies** was important.

### Lesson Learned

Infrastructure should be thought of as a dependency graph rather than a collection of independent resources.

---

# 2. Public vs Private Subnet Connectivity

Another significant challenge was understanding why resources inside private subnets could not simply access the internet.

Private EC2 instances required outbound internet access for tasks such as:

* Package installation
* Downloading dependencies
* Updating software
* Accessing external repositories

This required understanding:

```text
Private Subnet
      │
      ▼
Route Table
      │
      ▼
NAT Gateway
      │
      ▼
Internet Gateway
      │
      ▼
Internet
```

A missing route or incorrectly configured NAT Gateway could cause instance initialization scripts to fail.

### Lesson Learned

A private subnet does not automatically mean "no internet."

It means the resource does not have a direct route to the internet. Outbound connectivity can still be provided through a NAT Gateway.

---

# 3. EC2 User Data and Bootstrap Timing

Using user-data scripts introduced another challenge.

Terraform could successfully create an EC2 instance while the application inside the instance was still being configured.

This created situations where:

```text
Terraform:
"EC2 created successfully"

but

Application:
"Not ready yet"
```

The instance might need to:

1. Boot
2. Update packages
3. Install dependencies
4. Download application files
5. Configure Nginx
6. Start the application
7. Register with the load balancer

### Lesson Learned

Infrastructure creation and application readiness are not always the same event.

This distinction became particularly important when debugging load balancer health checks.

---

# 4. Nginx Configuration

Configuring Nginx correctly was another challenge.

A small configuration problem could prevent the entire frontend from working.

For example:

```nginx
proxy_pass http://backend;
```

requires the backend endpoint to be resolvable and reachable from the web server.

This meant that Nginx configuration had to align with:

* ALB configuration
* Security groups
* DNS/service discovery
* Backend port
* Application availability

### Lesson Learned

Application configuration and infrastructure configuration cannot be treated as completely separate systems.

The infrastructure must expose the endpoints the application expects.

---

# 5. Load Balancer Health Checks

Getting the load balancers to recognize instances as healthy required troubleshooting several layers.

A simplified request path was:

```text
Client
  │
  ▼
ALB
  │
  ▼
EC2
  │
  ▼
Nginx / Application
```

If the target was unhealthy, the problem could be caused by:

* Incorrect health-check path
* Wrong port
* Security group rules
* Nginx configuration
* Application not running
* Application listening on the wrong interface
* Instance initialization still running

### Lesson Learned

When troubleshooting ALB issues, check the complete request path instead of assuming the ALB itself is the problem.

---

# 6. Security Group Dependencies

Security groups initially required careful consideration because each tier needed to communicate with another tier without becoming unnecessarily exposed.

For example:

```text
Internet → Web
Web → App
App → Database
```

The database should not need:

```text
Internet → Database
```

This required designing security group rules based on **source and destination**, rather than simply opening ports broadly.

### Lesson Learned

Security groups should represent application relationships.

Instead of thinking:

> "Which ports should I open?"

I learned to think:

> "Which resource actually needs to communicate with this resource?"

---

# 7. Terraform State Management

Moving Terraform state into S3 introduced another important operational consideration.

Terraform depends heavily on its state file to understand what infrastructure it manages.

Without properly managed state, Terraform can lose track of the relationship between:

```text
Terraform Configuration
        │
        ▼
Terraform State
        │
        ▼
Actual AWS Resources
```

Remote state made the project more realistic but also required careful backend configuration.

### Lesson Learned

Terraform state is a critical part of Infrastructure as Code and should be treated as infrastructure data, not just another local file.

---

# 8. Handling Secrets and Sensitive Configuration

Another challenge was separating infrastructure configuration from sensitive application information.

Credentials such as:

* Database passwords
* JWT secrets
* API keys
* Access credentials

should not be hardcoded into Terraform files or committed to Git.

This required thinking carefully about:

```text
Terraform Code
       │
       ├── Infrastructure configuration
       │
       └── References to secrets
                    │
                    ▼
              Secret Store
```

### Lesson Learned

Infrastructure code should be reproducible without exposing credentials.

---

# 9. Application-to-Database Connectivity

Getting the application tier to communicate correctly with RDS required validating several things simultaneously:

```text
Application
    │
    ▼
Private Network
    │
    ▼
RDS Security Group
    │
    ▼
RDS Endpoint
    │
    ▼
MySQL
```

A connection failure could originate from:

* Incorrect database endpoint
* Incorrect credentials
* Wrong port
* Security group rules
* Route configuration
* Database availability
* Application environment variables

### Lesson Learned

Connectivity problems should be debugged layer by layer rather than changing multiple configurations at once.

---

# 10. Terraform Destroy and Resource Dependencies

Another important lesson was that creating infrastructure and destroying infrastructure are two different dependency problems.

Resources such as:

* NAT Gateways
* Load Balancers
* EC2 instances
* RDS
* Security Groups
* Network interfaces

can depend on one another.

Terraform needs to understand the correct order for destroying them.

### Lesson Learned

A good Terraform configuration should not only be able to create infrastructure—it should also be able to cleanly manage its lifecycle.

---

# 🧠 Key Technical Lessons

This project significantly strengthened my understanding of the relationship between infrastructure and applications.

Some of the most important lessons were:

### 1. Infrastructure is a system

A VPC, subnet, route table, security group, ALB, EC2 instance, and RDS database are not independent resources.

They form a system.

---

### 2. Networking is fundamental

Many application problems turned out to be networking problems.

Understanding:

* CIDR blocks
* routing
* subnets
* security groups
* NAT
* Internet Gateways
* load balancers

was essential.

---

### 3. Automation exposes hidden assumptions

Manual deployment can hide configuration problems.

Terraform forced infrastructure configuration to become explicit.

For example:

```text
Manual deployment:

"Just create the EC2."

Terraform:

"What subnet?
What security group?
What IAM role?
What AMI?
What user data?
What target group?
What dependency?
What route?
"
```

This made the infrastructure design much more deliberate.

---

### 4. Application and infrastructure must work together

Nginx, Node.js, ALB, security groups, DNS, and RDS all had to agree on:

* Ports
* Addresses
* Protocols
* Health checks
* Authentication
* Connectivity

A working application therefore required more than just working Terraform syntax.

---

# 🛠️ Terraform Workflow

The infrastructure was managed using the standard Terraform workflow.

## Initialize

```bash
terraform init
```

## Validate

```bash
terraform validate
```

## Format

```bash
terraform fmt -recursive
```

## Plan

```bash
terraform plan
```

## Apply

```bash
terraform apply
```

## Inspect Outputs

```bash
terraform output
```

## Destroy

When the environment was no longer required:

```bash
terraform destroy
```

---

# 🔍 Troubleshooting Methodology

One of the biggest outcomes of this project was developing a structured approach to troubleshooting.

Rather than immediately changing Terraform resources, I learned to trace the request path.

For example:

```text
Browser
  │
  ▼
CloudFront
  │
  ▼
ALB
  │
  ▼
Nginx
  │
  ▼
Internal ALB
  │
  ▼
Node.js
  │
  ▼
RDS
```

At every stage I could ask:

1. Is the resource running?
2. Is it reachable?
3. Is the port open?
4. Is the security group allowing the traffic?
5. Is the application listening?
6. Is the health check correct?
7. Is DNS resolving?
8. Is the next tier available?

This approach proved much more effective than randomly modifying infrastructure.

---

# 📊 High-Level Request Flow

A typical request follows this path:

```text
                    USER
                     │
                     ▼
                CloudFront
                     │
                     ▼
                 Public ALB
                     │
                     ▼
             ┌───────────────┐
             │   Web Tier    │
             │ EC2 + Nginx   │
             └───────┬───────┘
                     │
                     ▼
               Internal ALB
                     │
                     ▼
             ┌───────────────┐
             │  App Tier     │
             │ EC2 + Node.js │
             └───────┬───────┘
                     │
                     ▼
             ┌───────────────┐
             │   Amazon RDS  │
             │     MySQL     │
             └───────────────┘
```

---

# 📈 Future Improvements

Although the infrastructure was successfully automated, there are several areas where the project could be extended.

Potential improvements include:

* AWS WAF
* ACM-managed TLS certificates
* HTTPS-only traffic
* CloudWatch dashboards
* CloudWatch alarms
* Centralized logging
* AWS Systems Manager
* AWS Secrets Manager
* CI/CD with GitHub Actions
* Automated application deployment
* Terraform modules
* Terraform remote-state locking
* Infrastructure testing
* Blue/green deployments
* Disaster recovery strategy
* Multi-region architecture
* Containerization with Docker
* Migration from EC2 to ECS/EKS
* Automated security scanning
* Terraform security scanning with Checkov or tfsec

---

# 🎓 What This Project Demonstrates

This project demonstrates practical experience with:

### Cloud Infrastructure

* AWS VPC
* Subnet design
* Route tables
* Internet Gateway
* NAT Gateway
* EC2
* Auto Scaling
* ALB
* CloudFront
* RDS
* S3

### Infrastructure as Code

* Terraform
* Variables
* Outputs
* Resource dependencies
* State management
* Remote backend
* Infrastructure lifecycle management

### Linux / Systems Administration

* Amazon Linux
* Shell scripting
* Package management
* Nginx
* Systemd
* PM2
* Application configuration

### Networking

* CIDR addressing
* Public/private subnet design
* Routing
* NAT
* Security groups
* Load balancing
* Tier-to-tier communication

### Troubleshooting

* EC2 bootstrap failures
* ALB health checks
* Security group problems
* Routing problems
* Application connectivity
* Database connectivity
* Nginx configuration
* Terraform state and dependency issues

---

# 💡 Key Takeaway

The biggest lesson from this project was that **Cloud Engineering is not simply about creating AWS resources**.

The real challenge is making those resources work together reliably.

Terraform provided the mechanism for automating the infrastructure, but successfully deploying the application required understanding:

```text
Networking
     +
Security
     +
Compute
     +
Load Balancing
     +
Linux
     +
Web Servers
     +
Application Configuration
     +
Database Connectivity
     +
Infrastructure as Code
```

The project therefore became an exercise in understanding the entire infrastructure lifecycle:

```text
Design
  ↓
Provision
  ↓
Configure
  ↓
Deploy
  ↓
Test
  ↓
Troubleshoot
  ↓
Improve
  ↓
Destroy / Recreate
```

That is the primary value of this project: the infrastructure was not manually assembled once—it was **defined as code and designed to be reproducible**.

---

# 👨‍💻 Skills Demonstrated

```text
AWS
Terraform
Infrastructure as Code
Amazon VPC
EC2
Auto Scaling
Application Load Balancer
CloudFront
Amazon RDS
Amazon S3
IAM
Security Groups
Nginx
Linux
Shell Scripting
Node.js
PM2
MySQL
Networking
Troubleshooting
Cloud Architecture
```

---

# ⭐ Project Summary

**Project:** AWS Three-Tier Todo Application
**Approach:** Infrastructure as Code
**IaC Tool:** Terraform
**Compute:** Amazon EC2 + Auto Scaling
**Networking:** Amazon VPC
**Load Balancing:** Application Load Balancer
**CDN:** CloudFront
**Database:** Amazon RDS MySQL
**Storage:** Amazon S3
**Web Server:** Nginx
**Backend:** Node.js
**Process Manager:** PM2
**Operating System:** Amazon Linux

---

## 🚀 Final Outcome

The completed project resulted in a reproducible AWS three-tier environment where infrastructure could be provisioned through Terraform rather than manually creating individual AWS resources.

More importantly, the project provided practical experience in taking an application from:

**architecture → infrastructure → automation → configuration → deployment → troubleshooting → reproducibility.**

It served as a foundation for progressing toward more advanced cloud and DevOps architectures involving containers, Kubernetes, CI/CD, observability, security automation, and managed cloud services.
