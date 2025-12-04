#!/bin/bash
# AWS Infrastructure Setup Script
# This script sets up all AWS resources in the correct order

echo "Starting AWS Infrastructure Setup..."
echo "===================================="

# Function to apply Terraform resources
apply_terraform() {
    local dir=$1
    local name=$2
    
    if [ -d "$dir" ]; then
        echo "Setting up $name..."
        cd "$dir" || exit
        
        echo "Initializing Terraform..."
        terraform init
        
        if [ $? -ne 0 ]; then
            echo "❌ Terraform init failed for $name"
            exit 1
        fi
        
        echo "Planning changes..."
        terraform plan
        
        echo "Applying changes..."
        terraform apply -auto-approve
        
        if [ $? -eq 0 ]; then
            echo "✅ $name setup completed successfully"
        else
            echo "❌ Error setting up $name"
            exit 1
        fi
        
        cd ..
    else
        echo "❌ Directory $dir not found"
        exit 1
    fi
}

# Apply resources in order
echo "Step 1: Setting up VPC Infrastructure..."
apply_terraform "1_vpc" "VPC Infrastructure"

echo ""
echo "Step 2: Setting up EC2 Web Server..."
apply_terraform "2_ec2" "EC2 Web Server"

echo ""
echo "Step 3: Setting up Auto Scaling and Load Balancer..."
apply_terraform "3_ha_asg" "Auto Scaling and ALB"

echo ""
echo "Step 4: Setting up Billing Monitoring..."
apply_terraform "4_billing" "Billing Monitoring"

echo ""
echo "===================================="
echo "Setup completed!"
echo ""
echo "Next steps:"
echo "1. Check your email and confirm the SNS subscription for billing alerts"
echo "2. Capture screenshots of all components as required"
echo "3. Test the web applications (both direct EC2 and ALB endpoints)"
echo "4. Verify all resources are working correctly"
echo ""
echo "Useful commands:"
echo "- Check EC2 instances: aws ec2 describe-instances --region us-east-1"
echo "- Check ALB: aws elbv2 describe-load-balancers --region us-east-1"
echo "- Check ASG: aws autoscaling describe-auto-scaling-groups --region us-east-1"