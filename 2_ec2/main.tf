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
  description = "First name and last name for tagging and website"
  type        = string
  default     = "Krish_Maheshwari"
}

variable "user_ip" {
  description = "User IP address for SSH access"
  type        = string
  default     = "49.43.117.176/32"
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

data "aws_internet_gateway" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.first_name_last_name}-igw"]
  }
}

# Security Group for EC2 Instance
resource "aws_security_group" "web" {
  name        = "${var.first_name_last_name}-web-sg"
  description = "Security group for web server"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.user_ip]
    description = "SSH from user IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name      = "${var.first_name_last_name}-web-sg"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Key Pair for EC2 Instance
resource "aws_key_pair" "web" {
  key_name   = "${var.first_name_last_name}-web-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id # Use dynamic AMI
  instance_type          = "t3.micro"
  subnet_id                = data.aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.web.key_name

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    first_name_last_name = var.first_name_last_name
  }))

  tags = {
    Name      = "${var.first_name_last_name}-web-server"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "website_url" {
  description = "URL of the website"
  value       = "http://${aws_instance.web.public_ip}"
}
