#!/bin/bash
# AWS Infrastructure Cleanup Script
# This script destroys all AWS resources in reverse order

echo "Starting AWS Infrastructure Cleanup..."
echo "======================================="

# Function to destroy Terraform resources
destroy_terraform() {
    local dir=$1
    local name=$2
    
    if [ -d "$dir" ]; then
        echo "Destroying $name resources..."
        cd "$dir" || exit
        
        if [ -f "terraform.tfstate" ]; then
            terraform destroy -auto-approve
            if [ $? -eq 0 ]; then
                echo "✅ $name destroyed successfully"
            else
                echo "❌ Error destroying $name"
                exit 1
            fi
        else
            echo "⚠️  No terraform state found for $name, skipping..."
        fi
        
        cd ..
    else
        echo "⚠️  Directory $dir not found, skipping..."
    fi
}

# Destroy resources in reverse order
echo "Step 1: Destroying Billing Monitoring..."
destroy_terraform "4_billing" "Billing Monitoring"

echo ""
echo "Step 2: Destroying Auto Scaling and Load Balancer..."
destroy_terraform "3_ha_asg" "Auto Scaling and ALB"

echo ""
echo "Step 3: Destroying EC2 Web Server..."
destroy_terraform "2_ec2" "EC2 Web Server"

echo ""
echo "Step 4: Destroying VPC Infrastructure..."
destroy_terraform "1_vpc" "VPC Infrastructure"

echo ""
echo "======================================="
echo "Cleanup completed!"
echo ""
echo "Please verify in AWS Console that all resources have been deleted:"
echo "- No EC2 instances running"
echo "- No NAT Gateways or ALBs exist" 
echo "- No Elastic IPs are allocated"
echo "- No VPCs remain"
echo ""
echo "Don't forget to:"
echo "1. Delete the GitHub repository if no longer needed"
echo "2. Remove any local credentials from this machine"
echo "3. Check your email for any final billing notifications"