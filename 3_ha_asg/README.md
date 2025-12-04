# Task 3: High Availability and Auto Scaling

This directory contains Terraform configuration for creating a highly available web application using Application Load Balancer (ALB) and Auto Scaling Groups (ASG).

## Approach
I migrated the single EC2 instance to a highly available architecture:
- **Application Load Balancer (ALB)**: Placed in public subnets to handle incoming internet traffic and distribute it across zones.
- **Auto Scaling Group (ASG)**: Deployed in private subnets to ensure security (no direct internet access). It automatically scales instances (min 1, max 2) based on health and demand.
- **Traffic Flow**: Public Internet -> ALB -> Private EC2 Instances.
- **Health Checks**: The ALB monitors the `/` path to ensure traffic is only sent to healthy instances.


## Architecture Overview

- **Load Balancer**: Application Load Balancer (ALB) in public subnets
- **Auto Scaling**: Launch Template + Auto Scaling Group across private subnets
- **Instance Type**: t2.micro (Free Tier eligible)
- **Availability**: Multi-AZ deployment for high availability
- **Scaling**: Min=1, Max=2, Desired=1 instances

## Components Created

### 1. Application Load Balancer (ALB)
- **Resource**: `aws_lb.main`
- **Type**: Internet-facing Application Load Balancer
- **Subnets**: Public subnets in both AZs
- **Features**: HTTP/2 enabled, deletion protection disabled

### 2. Target Group
- **Resource**: `aws_lb_target_group.main`
- **Port**: 80 (HTTP)
- **Protocol**: HTTP
- **Health Checks**: Path `/` with 200 response matcher
- **Thresholds**: 2 healthy/unhealthy, 30s interval, 5s timeout

### 3. ALB Listener
- **Resource**: `aws_lb_listener.main`
- **Port**: 80 (HTTP)
- **Default Action**: Forward to target group

### 4. Launch Template
- **Resource**: `aws_launch_template.web`
- **AMI**: Amazon Linux 2
- **Instance Type**: t2.micro
- **Security Groups**: Existing web security group
- **User Data**: Custom script for ASG instances

### 5. Auto Scaling Group
- **Resource**: `aws_autoscaling_group.main`
- **Subnets**: Private subnets in both AZs
- **Scaling**: Min=1, Max=2, Desired=1
- **Health Check**: ELB-based with 300s grace period
- **Launch Template**: Latest version

### 6. Security Groups
- **ALB Security Group**: Allows HTTP from anywhere
- **Instance Security Group**: Allows HTTP only from ALB

## User Data Configuration

The ASG instances use a specialized user data script (`userdata-asg.sh`) that:

1. **System Setup**
   - Updates packages and installs Nginx
   - Configures automatic security updates

2. **Dynamic Website**
   - Creates responsive HTML page with instance metadata
   - Shows real-time instance information (ID, IP, AZ)
   - Includes Auto Scaling Group information
   - JavaScript-based metadata fetching

3. **Security Hardening**
   - Disables password authentication
   - Disables root login
   - Removes server tokens

## Key Features

### High Availability
- Multi-AZ deployment across us-east-1a and us-east-1b
- Automatic instance replacement on failure
- Load balancer distributes traffic across healthy instances

### Auto Scaling
- Automatically adjusts capacity based on demand
- Maintains minimum availability (1 instance)
- Scales up to maximum of 2 instances
- Health check integration with ALB

### Load Balancing
- Application-level load balancing
- Health checks ensure only healthy instances receive traffic
- Automatic failover to healthy instances

## Prerequisites

- VPC with public and private subnets (Task 1)
- Security group for web instances (Task 2)
- NAT instance for private subnet internet access (Task 1)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `alb_dns_name` - DNS name of the Application Load Balancer
- `alb_zone_id` - Zone ID of the ALB
- `target_group_arn` - ARN of the target group
- `autoscaling_group_name` - Name of the Auto Scaling Group
- `launch_template_id` - ID of the launch template

## Testing

After deployment, you can test the setup by:

1. Accessing the ALB DNS name in a browser
2. Refreshing multiple times to see different instance IDs
3. Terminating an instance to test auto-recovery
4. Checking the target group health status

## Security Features

- Instances in private subnets (no direct internet access)
- ALB security group allows only HTTP traffic
- Instance security group allows traffic only from ALB
- All resources tagged with Owner and DeleteOn tags

## Screenshots Required

The following screenshots should be captured after deployment:

1. **ALB Configuration** - showing listeners and target groups
2. **Target Group Health** - showing healthy instances
3. **Auto Scaling Group** - showing running instances
4. **EC2 Instances** - showing private IP addresses of ASG instances
5. **Website Screenshot** - showing the dynamic website with instance metadata

These screenshots should be saved in the `screenshots/` directory.