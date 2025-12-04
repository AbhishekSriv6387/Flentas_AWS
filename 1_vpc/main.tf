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

variable "user_ip" {
  description = "User IP address for SSH access"
  type        = string
  default     = "49.43.117.176/32"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
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

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "${var.first_name_last_name}-vpc"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.first_name_last_name}-igw"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.first_name_last_name}-public-a"
    Type      = "public"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.first_name_last_name}-public-b"
    Type      = "public"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name      = "${var.first_name_last_name}-private-a"
    Type      = "private"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name      = "${var.first_name_last_name}-private-b"
    Type      = "private"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Elastic IP for NAT Instance
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name      = "${var.first_name_last_name}-nat-eip"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# NAT Instance Security Group
resource "aws_security_group" "nat" {
  name        = "${var.first_name_last_name}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

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
    Name      = "${var.first_name_last_name}-nat-sg"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# NAT Instance
resource "aws_instance" "nat" {
  ami                    = data.aws_ami.amazon_linux_2.id # Use dynamic AMI
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.nat.id]
  source_dest_check      = false
  key_name               = aws_key_pair.main.key_name

  user_data = base64encode(templatefile("${path.module}/nat-userdata.sh", {}))

  tags = {
    Name      = "${var.first_name_last_name}-nat-instance"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Associate Elastic IP with NAT Instance
resource "aws_eip_association" "nat" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.nat.id
}

# Key Pair for NAT Instance
resource "aws_key_pair" "main" {
  key_name   = "${var.first_name_last_name}-key"
  public_key = file("${path.module}/id_rsa.pub")
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "${var.first_name_last_name}-public-rt"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id



  tags = {
    Name      = "${var.first_name_last_name}-private-rt"
    Owner     = var.first_name_last_name
    DeleteOn  = timestamp()
    Terraform = "true"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

# Route Table Associations
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "nat_eip" {
  description = "Elastic IP of NAT instance"
  value       = aws_eip.nat.public_ip
}
