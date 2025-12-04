terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "first_name_last_name" {
  description = "First name and last name for tagging"
  type        = string
  default     = "Krish_Maheshwari"
}

variable "user_email" {
  description = "User email for billing alerts"
  type        = string
  default     = "krishmaheshwari7991@gmail.com"
}

variable "billing_threshold" {
  description = "Billing alarm threshold in USD"
  type        = number
  default     = 1.20
}

# Data source for current account
data "aws_caller_identity" "current" {}

# SNS Topic for Billing Alerts
resource "aws_sns_topic" "billing_alerts" {
  name = "${var.first_name_last_name}-billing-alerts"

  tags = {
    Name      = "${var.first_name_last_name}-billing-alerts"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "billing_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.user_email
}

# CloudWatch Billing Alarm
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${var.first_name_last_name}-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # 6 hours
  statistic           = "Maximum"
  threshold           = var.billing_threshold
  alarm_description   = "This metric monitors estimated AWS charges"
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]

  tags = {
    Name      = "${var.first_name_last_name}-billing-alarm"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# CloudWatch Free Tier Usage Alarm (if available)
resource "aws_cloudwatch_metric_alarm" "free_tier_alarm" {
  alarm_name          = "${var.first_name_last_name}-free-tier-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeTierUsage"
  namespace           = "AWS/Billing"
  period              = "86400" # 24 hours
  statistic           = "Maximum"
  threshold           = 80
  alarm_description   = "This metric monitors Free Tier usage percentage"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.billing_alerts.arn]

  tags = {
    Name      = "${var.first_name_last_name}-free-tier-alarm"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# AWS Budget for cost tracking
resource "aws_budgets_budget" "monthly_budget" {
  name              = "${var.first_name_last_name}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.billing_threshold * 2 # Double the alarm threshold
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = formatdate("YYYY-MM-DD_00:00", timestamp())

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type           = "ACTUAL"
    subscriber_email_addresses = [var.user_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type           = "ACTUAL"
    subscriber_email_addresses = [var.user_email]
  }

  cost_filter {
    name = "Service"
    values = [
      "Amazon Elastic Compute Cloud - Compute",
      "Amazon Virtual Private Cloud",
      "Amazon Elastic Load Balancing",
      "AmazonCloudWatch"
    ]
  }

  tags = {
    Name      = "${var.first_name_last_name}-monthly-budget"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# IAM Role for Budgets (if needed)
resource "aws_iam_role" "budgets_role" {
  name = "${var.first_name_last_name}-budgets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name      = "${var.first_name_last_name}-budgets-role"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# IAM Policy for Budgets
resource "aws_iam_role_policy_attachment" "budgets_policy" {
  role       = aws_iam_role.budgets_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBudgetsReadOnlyAccess"
}

# Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.billing_alerts.arn
}

output "billing_alarm_arn" {
  description = "ARN of the billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.arn
}

output "free_tier_alarm_arn" {
  description = "ARN of the free tier alarm"
  value       = aws_cloudwatch_metric_alarm.free_tier_alarm.arn
}

output "budget_name" {
  description = "Name of the budget"
  value       = aws_budgets_budget.monthly_budget.name
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "billing_threshold" {
  description = "Billing alarm threshold"
  value       = var.billing_threshold
}
