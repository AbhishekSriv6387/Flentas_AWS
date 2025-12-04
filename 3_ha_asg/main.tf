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

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data sources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-vpc"]
  }
}

data "aws_subnet" "public_a" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-public-a"]
  }
}

data "aws_subnet" "public_b" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-public-b"]
  }
}

data "aws_subnet" "private_a" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-private-a"]
  }
}

data "aws_subnet" "private_b" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-private-b"]
  }
}

data "aws_security_group" "web" {
  vpc_id = data.aws_vpc.main.id
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-web-sg"]
  }
}

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "${var.first_name_last_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name      = "${var.first_name_last_name}-alb-sg"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = replace("${var.first_name_last_name}-alb", "_", "-")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [data.aws_subnet.public_a.id, data.aws_subnet.public_b.id]

  enable_deletion_protection = false
  enable_http2              = true

  tags = {
    Name      = "${var.first_name_last_name}-alb"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = replace("${var.first_name_last_name}-tg", "_", "-")
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name      = "${var.first_name_last_name}-tg"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "${var.first_name_last_name}-web-"
  image_id      = data.aws_ami.amazon_linux_2.id # Use dynamic AMI
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.web.id]
  }

  key_name = aws_key_pair.asg.key_name


  user_data = base64encode(templatefile("${path.module}/userdata-asg.sh", {
    first_name_last_name = var.first_name_last_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.first_name_last_name}-asg-instance"
      Owner     = var.first_name_last_name
      DeleteOn  = timestamp()
      Terraform = "true"
    }
  }

  tags = {
    Name      = "${var.first_name_last_name}-launch-template"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.first_name_last_name}-asg"
  vpc_zone_identifier = [data.aws_subnet.public_a.id, data.aws_subnet.public_b.id] # Changed to Public Subnets
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.first_name_last_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = var.first_name_last_name
    propagate_at_launch = true
  }

  tag {
    key                 = "DeleteOn"
    value               = timestamp()
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
}

# Outputs
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.web.id
}
