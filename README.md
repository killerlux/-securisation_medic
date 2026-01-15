# Secure SaaS EHR Platform (HIPAA/GDPR Compliant)

## Overview
This repository contains the security architecture and implementation reference for a Multi-tenant SaaS Electronic Health Record (EHR) platform. It is designed to meet strict HIPAA (US) and GDPR (EU) compliance requirements on AWS.

## Project Structure

```
.
├── .github/
│   └── workflows/          # CI/CD Pipelines (Security Scan, Deployment)
├── docs/
│   ├── architecture/       # System Design & Diagrams
│   └── compliance/         # Policies & Incident Response Plans
├── terraform/
│   └── modules/            # Infrastructure as Code (Security Hardened)
│       ├── database/       # RDS with Encryption
│       ├── network/        # WAF & VPC
│       └── security/       # KMS & IAM
└── backend/
    └── middleware/         # Python Middleware for Logging & Masking
```

## Key Features

### 1. Security Governance (Phase 1)
- **Architecture**: 3-Tier VPC isolation (Public, App, Data).
- **Compliance**: Data Classification Policy and Incident Response Plan.
- **Documentation**: [System Design](docs/architecture/system-design.md)

### 2. Infrastructure Security (Phase 2)
- **KMS**: Customer Managed Keys (CMK) with strict separation of duties.
- **RDS**: Multi-tenant isolation, forced SSL, and encryption at rest.
- **WAF**: Protection against SQLi, XSS, and rate limiting.

### 3. DevSecOps Automation (Phase 3)
- **IaC Scanning**: Checkov and TFLint integration.
- **Secret Detection**: TruffleHog deep scanning.
- **Deployment**: Blue/Green strategy with automated rollback.

### 4. Application Security (Phase 4)
- **Audit Logging**: JSON-structured, HIPAA-compliant access logs.
- **Data Masking**: Role-based redaction of PHI/PII.

## Deployment

### Prerequisites
- AWS Account
- Terraform v1.5+
- Python 3.10+

### Quick Start
1. **Infrastructure**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

2. **Backend**:
   ```bash
   cd backend
   pip install fastapi uvicorn
   ```

## License
Confidential & Proprietary.
