# Architecture Diagram

This diagram represents the actual infrastructure deployed via Terraform for the Flentas Assessment.

```mermaid
graph TD
    User[User] -->|HTTP/80| ALB[Application Load Balancer]
    
    subgraph VPC [VPC: 10.0.0.0/16]
        subgraph Public_Subnets [Public Subnets]
            ALB
            NAT[NAT Instance (t3.micro)]
            IGW[Internet Gateway]
        end
        
        subgraph Private_Subnets [Private Subnets]
            ASG[Auto Scaling Group]
            subgraph ASG_Instances [ASG Instances (t3.micro)]
                Instance1[Web Server 1]
                Instance2[Web Server 2]
            end
        end
    end

    ALB -->|Forward| ASG
    ASG --> Instance1
    ASG --> Instance2
    
    Instance1 -->|Outbound Traffic| NAT
    Instance2 -->|Outbound Traffic| NAT
    NAT -->|Internet Access| IGW
    
    classDef public fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef private fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    classDef component fill:#ffffff,stroke:#333,stroke-width:1px;
    
    class Public_Subnets public;
    class Private_Subnets private;
    class ALB,NAT,Instance1,Instance2 component;
```

## Key Components

1.  **VPC**: 10.0.0.0/16
2.  **Public Subnets**: Host the ALB and NAT Instance.
3.  **Private Subnets**: Host the Auto Scaling Group (Web Servers).
4.  **NAT Instance**: Provides outbound internet access for private instances (Cost Optimization).
5.  **ALB**: Distributes incoming HTTP traffic to the ASG.
6.  **Auto Scaling Group**: Manages `t3.micro` instances running Nginx.
