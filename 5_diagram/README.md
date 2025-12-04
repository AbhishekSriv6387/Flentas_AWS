# Task 5: Architecture Diagram

This directory contains the architecture diagram for the complete AWS infrastructure assessment project.

## Files

- `architecture.drawio` - Source file for the architecture diagram (editable in draw.io)
- `architecture.png` - Exported PNG version of the diagram
- `README.md` - This documentation file

## Architecture Overview

The diagram illustrates a complete multi-tier AWS infrastructure with the following components:

### Network Architecture
- **VPC**: 10.0.0.0/16 CIDR block
- **Public Subnets**: 2 subnets (10.0.1.0/24, 10.0.2.0/24) across 2 AZs
- **Private Subnets**: 2 subnets (10.0.101.0/24, 10.0.102.0/24) across 2 AZs
- **Internet Gateway**: Provides internet connectivity for public subnets

### Compute Architecture
- **Application Load Balancer**: Internet-facing ALB distributing traffic across private subnets
- **Auto Scaling Group**: Web servers in private subnets with automatic scaling (min=1, max=2)
- **NAT Instance**: t2.micro instance providing outbound internet access for private subnets
- **Bastion Host**: Optional SSH access point (shown as dashed line)

### Security Architecture
- **Security Groups**: ALB SG allows HTTP from internet, Web SG allows HTTP only from ALB
- **Network Isolation**: Private subnets have no direct internet access
- **SSH Access**: Restricted to user's IP address only

### Monitoring Architecture
- **CloudWatch**: Monitoring and alerting
- **SNS**: Email notifications for billing and system alerts
- **Billing Alarms**: Cost monitoring with $1.20 threshold

## Key Design Principles

### High Availability
- Multi-AZ deployment across us-east-1a and us-east-1b
- Auto Scaling Group automatically replaces failed instances
- Load balancer distributes traffic across healthy instances

### Security
- Defense in depth with multiple security layers
- Private subnets for application servers
- Security groups as virtual firewalls
- SSH access restricted to specific IP

### Scalability
- Auto Scaling automatically adjusts capacity
- Load balancer handles traffic distribution
- Infrastructure as Code enables rapid scaling

### Cost Optimization
- Free Tier eligible t2.micro instances
- NAT instance instead of NAT Gateway for cost savings
- Billing monitoring prevents unexpected charges

## Color Coding

- **Green**: Public subnets and internet-facing components
- **Purple**: Private subnets and internal components
- **Orange**: Load balancers and NAT devices
- **Red**: Internet Gateway
- **Blue**: Security groups and monitoring

## Usage

1. Open `architecture.drawio` in [draw.io](https://app.diagrams.net/)
2. Edit the diagram as needed
3. Export to PNG format for documentation
4. Update this README with any changes

## Technical Details

### Traffic Flow
1. Internet traffic hits the ALB in public subnets
2. ALB distributes traffic to healthy web servers in private subnets
3. Web servers respond through ALB back to users
4. Outbound traffic from private subnets goes through NAT instance

### Scaling Behavior
- Auto Scaling Group maintains minimum 1 instance
- Automatically scales up to 2 instances based on load
- Health checks ensure only healthy instances receive traffic
- Failed instances are automatically replaced

### Monitoring
- CloudWatch monitors instance health and performance
- Billing alarms track costs against $1.20 threshold
- SNS sends email notifications for critical events

This architecture demonstrates best practices for AWS infrastructure design including high availability, security, scalability, and cost optimization.