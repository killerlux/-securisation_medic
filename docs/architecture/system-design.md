# System Design Architecture

## Overview
This document outlines the high-level architecture for the Multi-tenant SaaS EHR platform, designed for HIPAA and GDPR compliance on AWS.

## Architecture Diagram

```mermaid
graph TD
    User[Mobile / Web App] -->|HTTPS| WAF[AWS WAF]
    WAF --> CF[CloudFront Distribution]
    CF --> ALB[Application Load Balancer]
    
    subgraph VPC [VPC (Multi-AZ)]
        subgraph Public_Subnet [Public Subnets]
            ALB
            NAT[NAT Gateway]
        end
        
        subgraph Private_App_Subnet [Private Application Subnets]
            EKS[EKS / Fargate Cluster]
            EKS -->|Logs| CW[CloudWatch]
        end
        
        subgraph Private_Data_Subnet [Private Data Subnets]
            RDS[RDS Multi-Tenant DB]
            ElastiCache[ElastiCache Redis]
        end
    end
    
    ALB --> EKS
    EKS --> RDS
    EKS --> ElastiCache
    
    KMS[AWS KMS] -.->|Encryption| RDS
    KMS -.->|Encryption| EKS
    
    S3[S3 Bucket - Encrypted]
    EKS --> S3
```

## VPC Design (3-Tier Isolation)

The network architecture enforces strict isolation using a 3-tier VPC design across multiple Availability Zones (AZs) for high availability.

### 1. Public Tier (DMZ)
- **Components**: Application Load Balancer (ALB), NAT Gateways, Bastion Hosts (if strictly necessary, accessed via Session Manager).
- **Access**: Internet-facing via Internet Gateway (IGW).
- **Security**: Protected by AWS WAF and Security Groups allowing only 443 (HTTPS) from CloudFront.

### 2. Private Application Tier
- **Components**: Application logic running on Amazon EKS with Fargate profiles.
- **Access**: No direct internet access. Outbound access via NAT Gateway for updates/API calls.
- **Security**: Security Groups allowing traffic only from the ALB security group.

### 3. Private Data Tier
- **Components**: Amazon RDS (PostgreSQL), Amazon ElastiCache.
- **Access**: Strictly isolated. No internet access.
- **Security**: Security Groups allowing traffic only from the Application Tier security group.
- **Multi-tenancy**: 
  - **RDS**: Implementation of Row-Level Security (RLS) or Schema-per-tenant to ensure strict data isolation.
  - **Encryption**: All data at rest encrypted using AWS KMS Customer Managed Keys (CMK).

