# Task 1: VPC and Subnetting

This directory contains Terraform configuration for creating a VPC with proper subnetting, Internet Gateway, and NAT instance setup.

## Approach
I designed a custom VPC with a CIDR block of `10.0.0.0/16` to provide ample IP address space. The network is segmented into public and private subnets across two Availability Zones (us-east-1a and us-east-1b) for high availability.
- **Public Subnets**: Host the NAT instance and are attached to the Internet Gateway for direct internet access.
- **Private Subnets**: Host internal resources and route outbound traffic through the NAT instance.
- **NAT Instance**: Chosen over NAT Gateway for **cost optimization** (Free Tier eligible), ensuring private instances can still download updates.


## Architecture Overview

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 2 subnets across 2 AZs
  - Public A: 10.0.1.0/24 (us-east-1a)
  - Public B: 10.0.2.0/24 (us-east-1b)
- **Private Subnets**: 2 subnets across 2 AZs
  - Private A: 10.0.101.0/24 (us-east-1a)
  - Private B: 10.0.102.0/24 (us-east-1b)

## Components Created

1. **VPC** (`aws_vpc.main`)
   - DNS hostnames and support enabled
   - Tagged with Owner and DeleteOn tags

2. **Internet Gateway** (`aws_internet_gateway.main`)
   - Attached to the VPC
   - Enables internet connectivity for public subnets

3. **Subnets** (4 total)
   - 2 public subnets with auto-assign public IP
   - 2 private subnets for backend resources
   - Distributed across 2 availability zones

4. **NAT Instance** (`aws_instance.nat`)
   - t2.micro instance in public subnet A
   - Elastic IP attached
   - Configured for IP forwarding and NAT
   - Security hardened with SSH key-only access

5. **Route Tables**
   - Public route table: routes 0.0.0.0/0 to Internet Gateway
   - Private route table: routes 0.0.0.0/0 to NAT instance

## Security Features

- NAT instance security group allows SSH only from user IP
- Password authentication disabled on NAT instance
- Automatic security updates enabled
- All resources tagged with Owner and DeleteOn tags

## Required Files

- `main.tf` - Main Terraform configuration
- `nat-userdata.sh` - NAT instance setup script
- `id_rsa.pub` - SSH public key file (to be provided by user)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `vpc_id` - ID of the created VPC
- `public_subnet_ids` - IDs of public subnets
- `private_subnet_ids` - IDs of private subnets
- `internet_gateway_id` - ID of the Internet Gateway
- `nat_instance_id` - ID of the NAT instance
- `nat_eip` - Elastic IP of NAT instance

## Screenshots Required

The following screenshots should be captured after deployment:

1. VPC Overview - showing the created VPC
2. Subnets List - showing all 4 subnets with their CIDRs and AZs
3. Route Tables - showing public and private route tables
4. NAT Instance - showing the running NAT instance details
5. Internet Gateway - showing the attached IGW

These screenshots should be saved in the `screenshots/` directory.