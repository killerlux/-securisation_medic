# Incident Response Plan (Data Breach Playbook)

## Objective
To provide a structured approach for handling security incidents, specifically data breaches involving PHI, ensuring compliance with HIPAA Breach Notification Rule and GDPR.

## Roles and Responsibilities
- **Incident Commander (IC)**: Lead responsible for overall management.
- **Security Lead**: Technical analysis and containment.
- **Legal Counsel**: Regulatory advice and notification determination.
- **Communications**: Managing internal and external messaging.

## Phases of Incident Response

### 1. Preparation
- Maintain up-to-date asset inventory and network diagrams.
- Regular training on PHI handling.
- Configure monitoring and alerting (GuardDuty, Security Hub, CloudWatch).
- Pre-establish communication channels (e.g., secure Slack channel).

### 2. Identification & Detection
- **Sources**: Automated alerts (IDS/IPS, WAF, DLP), user reports, anomaly detection.
- **Action**: 
  - Verify the incident (False Positive check).
  - Classify severity (Low, Medium, High, Critical).
  - Declare incident if confirmed.
  - Create an Incident Ticket.

### 3. Containment
- **Short-term**:
  - Isolate affected instances (remove from Security Groups, revoke IAM roles).
  - Block malicious IPs via WAF/NACL.
  - Rotate compromised credentials immediately.
- **Long-term**:
  - Apply patches or configuration changes to prevent spread.
  - **Preserve Evidence**: Snapshot EBS volumes, capture memory dumps *before* termination.

### 4. Eradication
- Remove the root cause (e.g., delete malware, disable vulnerable accounts).
- Rebuild compromised systems from known good state (Infrastructure as Code).
- Verify no backdoors remain.

### 5. Recovery
- Restore data from clean backups (verify integrity first).
- Restore systems to production incrementally.
- Monitor continuously for signs of recurrence.

### 6. Post-Incident Activity
- **Lessons Learned**: Conduct a retrospective within 48 hours.
- **Report**: Generate a detailed incident report (Root Cause Analysis).
- **Update**: Refine this Incident Response Plan based on findings.

## Notification (HIPAA & GDPR)
*Consult Legal Counsel before any notification.*

### HIPAA (US)
- **Individual Notice**: Notify affected individuals without unreasonable delay (max 60 days).
- **HHS Notice**: If >500 individuals, notify HHS immediately (max 60 days). If <500, log for annual report.
- **Media Notice**: If >500 residents of a state/jurisdiction are affected.

### GDPR (EU)
- **Supervisory Authority**: Notify within 72 hours of becoming aware of the breach, unless unlikely to risk rights/freedoms.
- **Data Subjects**: Notify without undue delay if high risk to rights/freedoms.

## Contact List
- **CISO**: [Phone/Email]
- **AWS Support**: [Account Info]
- **Legal**: [Phone/Email]

