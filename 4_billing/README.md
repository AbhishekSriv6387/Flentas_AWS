# Task 4: Billing and Free Tier Monitoring

This directory contains Terraform configuration for setting up billing alerts and monitoring to track AWS costs and Free Tier usage.

## Approach
Cost monitoring is critical for beginners to avoid unexpected charges from leaving resources running.
- **Billing Alarm**: Configured a CloudWatch alarm to trigger if estimated charges exceed $1.20 (approx ₹100).
- **Free Tier Alerts**: Enabled alerts to notify when Free Tier usage limits (e.g., EC2 hours, S3 storage) are approaching.
- **Notifications**: Both alarms send notifications to an SNS topic, which emails the user.
- **Sudden Bill Increases**: Often caused by leaving large instances running, unreleased Elastic IPs, or excessive data transfer.


## Architecture Overview

- **Billing Alarm**: CloudWatch alarm for estimated charges
- **Free Tier Alarm**: CloudWatch alarm for Free Tier usage percentage
- **Budget**: AWS Budgets for monthly cost tracking
- **SNS Notifications**: Email alerts for billing events
- **Threshold**: $1.20 USD (equivalent to ₹100)

## Components Created

### 1. SNS Topic and Subscription
- **Resource**: `aws_sns_topic.billing_alerts`
- **Purpose**: Central notification topic for billing events
- **Subscription**: Email notification to user

### 2. CloudWatch Billing Alarm
- **Resource**: `aws_cloudwatch_metric_alarm.billing_alarm`
- **Metric**: AWS/Billing EstimatedCharges
- **Threshold**: $1.20 USD
- **Period**: 6 hours
- **Action**: SNS notification when exceeded

### 3. CloudWatch Free Tier Alarm
- **Resource**: `aws_cloudwatch_metric_alarm.free_tier_alarm`
- **Metric**: AWS/Billing FreeTierUsage
- **Threshold**: 80% usage
- **Period**: 24 hours
- **Action**: SNS notification when exceeded

### 4. AWS Budget
- **Resource**: `aws_budgets_budget.monthly_budget`
- **Type**: COST budget
- **Limit**: $2.40 (double the alarm threshold)
- **Time Unit**: Monthly
- **Notifications**: 80% and 100% thresholds

### 5. IAM Role (Optional)
- **Resource**: `aws_iam_role.budgets_role`
- **Purpose**: Budgets service access role
- **Policy**: AWSBudgetsReadOnlyAccess

## Key Features

### Cost Monitoring
- Real-time tracking of estimated charges
- Email notifications when threshold exceeded
- Monthly budget tracking with multiple alert levels

### Free Tier Monitoring
- Tracks usage percentage against Free Tier limits
- Alerts when approaching Free Tier limits
- Helps prevent unexpected charges

### Multi-Level Alerts
- 80% threshold for early warning
- 100% threshold for critical alert
- Budget notifications at multiple levels

## Configuration

### Variables
- `user_email`: Email address for notifications
- `billing_threshold`: Alarm threshold in USD (default: $1.20)
- `aws_region`: AWS region (default: us-east-1)

### Email Subscription
The SNS email subscription requires manual confirmation:
1. Check your email after deployment
2. Click the confirmation link
3. Subscription will be activated

## Prerequisites

- AWS account with billing alerts enabled
- Valid email address for notifications
- Appropriate IAM permissions for CloudWatch and Budgets

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Email Confirmation

After deployment, you must confirm the email subscription:

1. Check your email for "AWS Notification - Subscription Confirmation"
2. Click the confirmation link in the email
3. You will receive a confirmation message

## Testing

To test the billing alerts:

1. **Billing Alarm**: Create some AWS resources to generate charges
2. **Free Tier Alarm**: Use services that count against Free Tier limits
3. **Budget Alerts**: Monitor monthly spending

## Cost Optimization

### Free Tier Eligible Services
- EC2 t2.micro instances (750 hours/month)
- S3 storage (5GB)
- CloudWatch metrics (10 custom metrics)
- ELB (750 hours/month)

### Cost Monitoring Best Practices
- Set up multiple billing alerts at different thresholds
- Monitor Free Tier usage regularly
- Review AWS Cost Explorer for detailed analysis
- Use AWS Budgets for detailed cost tracking

## Outputs

- `sns_topic_arn` - ARN of the SNS topic for billing alerts
- `billing_alarm_arn` - ARN of the billing CloudWatch alarm
- `free_tier_alarm_arn` - ARN of the Free Tier CloudWatch alarm
- `budget_name` - Name of the AWS Budget
- `account_id` - AWS Account ID
- `billing_threshold` - Configured billing threshold

## Screenshots Required

The following screenshots should be captured after deployment:

1. **CloudWatch Billing Alarm** - showing alarm configuration and status
2. **Free Tier Alerts** - showing Free Tier usage monitoring (AWS Console)
3. **SNS Subscription** - showing email subscription confirmation
4. **AWS Budget** - showing budget configuration and alerts

These screenshots should be saved in the `screenshots/` directory.

## Important Notes

- Billing alerts may take up to 6 hours to trigger after resource creation
- Free Tier usage resets monthly
- Budget notifications are sent based on actual spending
- Always confirm email subscriptions to receive alerts