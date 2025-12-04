# Task 5: Scalable Web Application Architecture (10,000 Concurrent Users)

This document describes the architecture for a highly scalable web application capable of handling 10,000 concurrent users, as required for Task 5.

## Architecture Diagram

You can use the following Mermaid diagram as a reference to create your draw.io diagram.

```mermaid
graph TD
    User[Users] -->|HTTPS| CDN[CloudFront CDN]
    User -->|DNS| R53[Route 53]
    R53 --> CDN
    CDN -->|Requests| WAF[AWS WAF]
    WAF -->|Filtered Traffic| ALB[Application Load Balancer]
    
    subgraph VPC [VPC]
        subgraph Public_Subnets [Public Subnets (Multi-AZ)]
            ALB
            NAT[NAT Gateways]
            Bastion[Bastion Host]
        end
        
        subgraph Private_App_Subnets [Private App Subnets (Multi-AZ)]
            ASG[Auto Scaling Group]
            Web1[Web Server 1]
            Web2[Web Server 2]
            WebN[Web Server N]
            ASG --> Web1
            ASG --> Web2
            ASG --> WebN
        end
        
        subgraph Private_Data_Subnets [Private Data Subnets (Multi-AZ)]
            Redis[ElastiCache Redis Cluster]
            RDS_Primary[RDS Primary (Writer)]
            RDS_Standby[RDS Standby (Reader)]
            RDS_Primary <-->|Replication| RDS_Standby
        end
    end
    
    ALB -->|Traffic| ASG
    Web1 -->|Cache| Redis
    Web2 -->|Cache| Redis
    Web1 -->|DB| RDS_Primary
    Web2 -->|DB| RDS_Primary
    Web1 -->|Outbound| NAT
    
    S3[S3 Bucket (Static Assets)]
    CDN -->|Origin| S3
    
    CW[CloudWatch] -.->|Monitoring| ALB
    CW -.->|Monitoring| ASG
    CW -.->|Monitoring| RDS_Primary
```

## Architecture Explanation

This architecture is designed for high availability, scalability, and security to handle 10,000 concurrent users.

### 1. Load Balancing & Traffic Management
- **Route 53**: Manages DNS and routes users to the nearest endpoint.
- **CloudFront CDN**: Caches static content (images, CSS, JS) at the edge to reduce load on the servers and improve latency.
- **AWS WAF**: Protects against common web exploits (SQL injection, XSS) before traffic reaches the ALB.
- **Application Load Balancer (ALB)**: Distributes incoming application traffic across multiple targets (EC2 instances) in different Availability Zones.

### 2. Compute Layer (Auto Scaling)
- **Auto Scaling Group (ASG)**: Automatically adjusts the number of EC2 instances based on demand (CPU utilization or request count).
- **Multi-AZ Deployment**: Instances are distributed across multiple Availability Zones to ensure availability even if one AZ fails.
- **Private Subnets**: Application servers are placed in private subnets for security, with no direct internet access.

### 3. Data Layer
- **Amazon RDS (Aurora)**: Managed relational database with Multi-AZ deployment for high availability and read replicas for scaling read operations.
- **ElastiCache (Redis)**: In-memory caching layer to store frequently accessed data (sessions, database queries), significantly reducing database load and improving response times.

### 4. Networking & Security
- **VPC**: Isolated network environment.
- **Public Subnets**: Host public-facing resources like ALB and NAT Gateways.
- **Private Subnets**: Host application servers and databases.
- **NAT Gateways**: Allow private instances to access the internet (e.g., for updates) without being exposed to inbound traffic.
- **Security Groups**: Act as virtual firewalls to control traffic at the instance level (e.g., allow DB access only from App servers).
- **NACLs**: Stateless network traffic filtering at the subnet level.

### 5. Observability
- **CloudWatch**: Monitors metrics (CPU, memory, disk I/O) and triggers alarms for Auto Scaling.
- **CloudWatch Logs**: Centralized logging for application and system logs.
- **X-Ray**: Traces requests through the application to identify performance bottlenecks.

## Why this handles 10,000 users?
- **Horizontal Scaling**: ASG adds more servers as traffic increases.
- **Caching**: Redis and CloudFront offload the majority of read requests.
- **Database Scaling**: Read replicas handle read-heavy workloads.
- **Load Balancing**: ALB prevents any single server from being overwhelmed.
