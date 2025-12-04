# Task 2: EC2 Static Website on Nginx

This directory contains Terraform configuration for launching an EC2 instance with Nginx serving a static resume website.

## Approach
I deployed a `t3.micro` EC2 instance in a public subnet to serve as the web server.
- **Nginx**: Installed via `user_data` script to serve the static HTML content.
- **Static Website**: A professional HTML resume is generated dynamically by the script.
- **Hardening**: Security best practices were applied by disabling password authentication, disabling root login, and enabling automatic security updates (`yum-cron`).
- **Access**: The Security Group allows HTTP (80) from anywhere but restricts SSH (22) to your specific IP address.


## Architecture Overview

- **Instance Type**: t2.micro (Free Tier eligible)
- **AMI**: Amazon Linux 2
- **Location**: Public Subnet A (us-east-1a)
- **Web Server**: Nginx
- **Content**: Static HTML resume with professional styling

## Components Created

1. **EC2 Instance** (`aws_instance.web`)
   - t2.micro instance in public subnet A
   - Public IP address assigned
   - SSH key pair for secure access

2. **Security Group** (`aws_security_group.web`)
   - HTTP (port 80) open to 0.0.0.0/0
   - SSH (port 22) restricted to user IP only
   - All outbound traffic allowed

3. **Key Pair** (`aws_key_pair.web`)
   - SSH key pair for instance access
   - Uses public key from `id_rsa.pub` file

## User Data Configuration

The instance runs a comprehensive setup script (`userdata.sh`) that:

1. **System Updates**
   - Updates all packages using yum
   - Configures automatic security updates

2. **Nginx Installation**
   - Installs and starts Nginx web server
   - Configures basic security settings

3. **Website Deployment**
   - Creates a professional HTML resume
   - Includes responsive CSS styling
   - Contains placeholder for user's name

4. **Security Hardening**
   - Disables password authentication
   - Disables root login
   - Removes server tokens from HTTP headers

## Website Content

The deployed website includes:
- Professional resume layout with contact information
- Technical skills section with cloud/AWS technologies
- Work experience and education sections
- Certifications and projects
- Responsive design for mobile compatibility

## Prerequisites

- VPC and subnets must be created first (Task 1)
- SSH public key file (`id_rsa.pub`) must exist
- User IP address for SSH access restrictions

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `instance_id` - ID of the EC2 instance
- `public_ip` - Public IP address of the instance
- `public_dns` - Public DNS name of the instance
- `website_url` - Direct URL to access the website

## Security Features

- SSH access restricted to user's IP address only
- Password authentication disabled
- Root login disabled
- Automatic security updates enabled
- All resources tagged with Owner and DeleteOn tags

## Screenshots Required

The following screenshots should be captured after deployment:

1. **EC2 Instance List** - showing the running web server instance
2. **Security Group Inbound Rules** - showing HTTP and SSH rules
3. **Browser Screenshot** - showing the deployed resume website at `http://<public_ip>/`

These screenshots should be saved in the `screenshots/` directory.