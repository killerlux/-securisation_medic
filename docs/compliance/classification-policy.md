# Data Classification & PHI Handling Policy

## Purpose
This policy defines the classification of data within the SaaS EHR platform and establishes handling requirements to ensure compliance with HIPAA (US) and GDPR (EU).

## Data Classification Levels

### Level 1: Public
- **Definition**: Information intended for public release.
- **Examples**: Marketing materials, privacy policy, terms of service.
- **Handling**: No special encryption required.

### Level 2: Internal
- **Definition**: Business operations data not containing sensitive personal info.
- **Examples**: Internal wikis, non-production configurations, application logs (sanitized).
- **Handling**: Access restricted to employees. Encrypted at rest.

### Level 3: Confidential (PII/Sensitive)
- **Definition**: Personally Identifiable Information that is not health-related.
- **Examples**: Employee records, vendor contracts, user email addresses.
- **Handling**: Access on need-to-know basis. Encrypted at rest and in transit.

### Level 4: Restricted (PHI - Protected Health Information)
- **Definition**: Any information about health status, provision of health care, or payment for health care that can be linked to a specific individual.
- **Examples**: Medical records, lab results, insurance details, patient IDs, biometric data.
- **Handling**: **Strictly Controlled**.
  - **Encryption**: Mandatory At Rest (AES-256 via KMS CMK) and In Transit (TLS 1.2+).
  - **Access Control**: Role-Based Access Control (RBAC) with Least Privilege.
  - **Auditing**: All access and modification events must be logged to a tamper-proof audit trail.
  - **Retention**: Retained only for the duration required by law or business need.

## PHI Handling Rules

1.  **Data Minimization**: Collect only the PHI absolutely necessary for the service.
2.  **De-identification**: Whenever possible, use de-identified data for analytics or research.
3.  **Production Data in Non-Prod**: **Strictly Prohibited**. Synthetic data must be used for development and testing environments.
4.  **Logging**: PHI must **never** be written to application logs. Use token references if necessary.
5.  **Access Reviews**: User access rights to PHI must be reviewed quarterly.
6.  **Third-Party Sharing**: PHI may only be shared with third parties who have a signed Business Associate Agreement (BAA).

## Technical Controls
- **AWS KMS**: Use Customer Managed Keys for PHI encryption to allow immediate revocation of access.
- **CloudWatch Logs**: Enable CloudTrail and VPC Flow Logs. Configure alerts for unauthorized access attempts.
- **Database**: Enable Row-Level Security (RLS) to enforce tenant isolation.

