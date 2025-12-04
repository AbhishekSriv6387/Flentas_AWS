# AWS Infrastructure Assessment

This repository contains Terraform configurations for AWS infrastructure assessment tasks including VPC setup, EC2 deployment, Auto Scaling, Load Balancing, and billing monitoring.

## Repository Structure

```
├── 1_vpc/
│   ├── main.tf              # VPC, subnets, IGW, NAT instance configuration
│   ├── README.md            # Task 1 documentation
│   └── screenshots/         # VPC screenshots
├── 2_ec2/
│   ├── main.tf              # EC2 instance with Nginx setup
│   ├── README.md            # Task 2 documentation
│   └── screenshots/         # EC2 screenshots
├── 3_ha_asg/
│   ├── main.tf              # ALB, Auto Scaling Group configuration
│   ├── README.md            # Task 3 documentation
│   └── screenshots/         # ALB/ASG screenshots
├── 4_billing/
│   ├── main.tf              # CloudWatch billing alarms
│   ├── README.md            # Task 4 documentation
│   └── screenshots/         # Billing screenshots
├── 5_diagram/
│   ├── architecture.drawio  # Architecture diagram source
│   ├── architecture.png   # Exported PNG diagram
│   └── README.md            # Diagram documentation
├── logs/                    # Error logs and outputs
└── results/                # Final summary and outputs
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version >= 1.0)
- GitHub account with personal access token

## Usage

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_NAME-aws-assessment.git
cd YOUR_NAME-aws-assessment
```

### 2. Set up AWS credentials
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. Deploy each task

#### Task 1: VPC Setup
```bash
cd 1_vpc
terraform init
terraform plan
terraform apply
```

#### Task 2: EC2 Instance
```bash
cd ../2_ec2
terraform init
terraform plan
terraform apply
```

#### Task 3: HA and Auto Scaling
```bash
cd ../3_ha_asg
terraform init
terraform plan
terraform apply
```

#### Task 4: Billing Monitoring
```bash
cd ../4_billing
terraform init
terraform plan
terraform apply
```

## Network Configuration

### VPC CIDR: 10.0.0.0/16
- **Public Subnet A**: 10.0.1.0/24 (us-east-1a)
- **Public Subnet B**: 10.0.2.0/24 (us-east-1b)
- **Private Subnet A**: 10.0.101.0/24 (us-east-1a)
- **Private Subnet B**: 10.0.102.0/24 (us-east-1b)

## Teardown Instructions

To destroy all resources (reverse order):

```bash
# Start from billing (Task 4)
cd 4_billing
terraform destroy

# Then HA/ASG (Task 3)
cd ../3_ha_asg
terraform destroy

# Then EC2 (Task 2)
cd ../2_ec2
terraform destroy

# Finally VPC (Task 1)
cd ../1_vpc
terraform destroy
```

## Important Notes

- All resources are tagged with `Owner` and `DeleteOn` tags
- Billing alarm is set to $1.20 USD (equivalent to ₹100)
- NAT instance is used instead of NAT Gateway for cost savings
- All instances use t2.micro (Free Tier eligible)

## Screenshots

Screenshots are captured for each task and stored in respective `screenshots/` directories:

- VPC overview, subnets, route tables, NAT instance
- EC2 instance, security groups, website screenshot
- ALB configuration, target groups, ASG instances
- CloudWatch billing alarms, Free Tier alerts

## Architecture Diagram

The complete architecture diagram is available in `5_diagram/architecture.png` showing:
- Multi-tier networking (public/private subnets)
- ALB with ASG web tier
- NAT instance for private subnet access
- Security groups and NACLs
- CloudWatch monitoring
- Optional bastion host

## Support

For issues or questions, please check the individual task README files for specific details about each component.