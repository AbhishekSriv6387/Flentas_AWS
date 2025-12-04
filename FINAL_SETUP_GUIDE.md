# AWS Infrastructure Assessment - Complete Setup Guide

This guide provides step-by-step instructions for setting up the complete AWS infrastructure assessment project.

## Prerequisites

Before starting, ensure you have:

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
3. **AWS CLI** configured with your credentials
4. **GitHub Account** with personal access token
5. **SSH Key Pair** for EC2 access
6. **Your public IP address** (for SSH security)

## Quick Start

### 1. Clone and Setup Repository

```bash
# Clone this repository (after GitHub repo is created)
git clone https://github.com/YOUR_USERNAME/YOUR_NAME-aws-assessment.git
cd YOUR_NAME-aws-assessment

# Make scripts executable
chmod +x setup.sh cleanup.sh
```

### 2. Configure Variables

Replace placeholder values in all Terraform files:

```bash
# Find and replace all placeholder values
find . -name "*.tf" -exec sed -i 's/Krish_Maheshwari/YOUR_ACTUAL_NAME/g' {} \;
find . -name "*.sh" -exec sed -i 's/Krish_Maheshwari/YOUR_ACTUAL_NAME/g' {} \;
find . -name "*.md" -exec sed -i 's/Krish_Maheshwari/YOUR_ACTUAL_NAME/g' {} \;

# Update email address
find . -name "*.tf" -exec sed -i 's/krish.maheshwari@example.com/YOUR_EMAIL/g' {} \;

# Update IP address
find . -name "*.tf" -exec sed -i 's/0.0.0.0\/32/YOUR_IP\/32/g' {} \;
```

### 3. Add SSH Keys

Replace the placeholder SSH keys with your actual public key:

```bash
# Replace SSH public key placeholders
echo "YOUR_ACTUAL_SSH_PUBLIC_KEY" > 1_vpc/id_rsa.pub
echo "YOUR_ACTUAL_SSH_PUBLIC_KEY" > 2_ec2/id_rsa.pub
echo "YOUR_ACTUAL_SSH_PUBLIC_KEY" > 3_ha_asg/id_rsa.pub
```

### 4. Deploy Infrastructure

Use the automated setup script:

```bash
./setup.sh
```

Or deploy manually step by step:

```bash
# Deploy VPC infrastructure
cd 1_vpc
terraform init
terraform plan
terraform apply
cd ..

# Deploy EC2 web server
cd 2_ec2
terraform init
terraform plan
terraform apply
cd ..

# Deploy Auto Scaling and Load Balancer
cd 3_ha_asg
terraform init
terraform plan
terraform apply
cd ..

# Deploy billing monitoring
cd 4_billing
terraform init
terraform plan
terraform apply
cd ..
```

## Manual Deployment Steps

### Task 1: VPC Setup

```bash
cd 1_vpc
terraform init
terraform plan
terraform apply
```

**Expected outputs:**
- VPC ID
- Public and Private Subnet IDs
- Internet Gateway ID
- NAT Instance ID and Elastic IP

### Task 2: EC2 Web Server

```bash
cd 2_ec2
terraform init
terraform plan
terraform apply
```

**Expected outputs:**
- Instance ID
- Public IP address
- Website URL

### Task 3: Auto Scaling and Load Balancer

```bash
cd 3_ha_asg
terraform init
terraform plan
terraform apply
```

**Expected outputs:**
- ALB DNS name
- Target Group ARN
- Auto Scaling Group name

### Task 4: Billing Monitoring

```bash
cd 4_billing
terraform init
terraform plan
terraform apply
```

**Expected outputs:**
- SNS Topic ARN
- Billing Alarm ARN
- Budget name

## Post-Deployment Tasks

### 1. Confirm Email Subscription

Check your email and confirm the SNS subscription for billing alerts:

1. Look for email from AWS Notifications
2. Click the confirmation link
3. You'll receive a confirmation message

### 2. Capture Screenshots

Take screenshots of all components:

#### Task 1 Screenshots
- [ ] VPC Overview in AWS Console
- [ ] Subnets list showing all 4 subnets
- [ ] Route tables (public and private)
- [ ] NAT instance details
- [ ] Internet Gateway attachment

#### Task 2 Screenshots
- [ ] EC2 instance list showing running instance
- [ ] Security group inbound rules
- [ ] Browser screenshot of website at `http://<public-ip>/`

#### Task 3 Screenshots
- [ ] ALB configuration and listeners
- [ ] Target group health checks
- [ ] Auto Scaling Group instances
- [ ] EC2 instances launched by ASG (private IPs)
- [ ] Browser screenshot of ALB endpoint

#### Task 4 Screenshots
- [ ] CloudWatch billing alarm configuration
- [ ] Free Tier usage alerts in AWS Console
- [ ] SNS subscription confirmation
- [ ] AWS Budget configuration

### 3. Test the Setup

#### Test Web Applications
```bash
# Test direct EC2 instance
curl http://<ec2-public-ip>

# Test ALB endpoint
curl http://<alb-dns-name>
```

#### Test Auto Scaling
```bash
# Terminate one instance and watch ASG replace it
aws autoscaling describe-auto-scaling-groups --region us-east-1
```

#### Test Billing Alerts
- Monitor CloudWatch billing metrics
- Check that SNS notifications work

## Architecture Diagram

The complete architecture is documented in `5_diagram/architecture.drawio` and exported as `architecture.png`.

## Cleanup Instructions

To destroy all resources:

```bash
./cleanup.sh
```

Or manually destroy in reverse order:

```bash
cd 4_billing && terraform destroy && cd ..
cd 3_ha_asg && terraform destroy && cd ..
cd 2_ec2 && terraform destroy && cd ..
cd 1_vpc && terraform destroy && cd ..
```

## Verification Checklist

After cleanup, verify in AWS Console:

- [ ] No EC2 instances running
- [ ] No NAT Gateways or ALBs exist
- [ ] No Elastic IPs are allocated
- [ ] No VPCs remain (except default)
- [ ] No CloudWatch alarms active
- [ ] No SNS topics remain

## Troubleshooting

### Common Issues

1. **SSH Key Issues**
   - Ensure your public key is in correct format
   - Verify key permissions are set correctly

2. **Terraform State Issues**
   - Run `terraform refresh` to update state
   - Check AWS credentials are configured

3. **Billing Alerts Not Working**
   - Confirm email subscription is confirmed
   - Check CloudWatch metrics are available

4. **Instances Not Launching**
   - Verify subnet configurations
   - Check security group rules
   - Ensure AMI ID is valid for your region

### Getting Help

Check individual task README files for specific troubleshooting:
- `1_vpc/README.md`
- `2_ec2/README.md`
- `3_ha_asg/README.md`
- `4_billing/README.md`

## Security Best Practices

- SSH access restricted to your IP only
- Private subnets for application servers
- Security groups as virtual firewalls
- Regular security updates enabled
- All resources properly tagged

## Cost Optimization

- Use Free Tier eligible t2.micro instances
- NAT instance instead of NAT Gateway
- Monitor costs with billing alerts
- Clean up resources when done

## Final Deliverables

1. **GitHub Repository** with all code
2. **Screenshots** for all tasks
3. **Architecture Diagram** showing complete setup
4. **Summary Report** with all outputs and URLs

Commit all changes and push to GitHub:

```bash
git add .
git commit -m "Complete AWS Infrastructure Assessment"
git push origin main
```

## Next Steps

1. Share GitHub repository link
2. Provide screenshot collection
3. Confirm all resources are cleaned up
4. Submit final assessment

---

**Note**: Remember to replace all placeholder values with your actual information before deployment!
