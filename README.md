# SecureFlow — Enterprise DevSecOps CI/CD Security Pipeline on AWS

<div align="center">

![AWS](https://img.shields.io/badge/AWS-Cloud%20Security-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![tfsec](https://img.shields.io/badge/tfsec-IaC%20Security-2E8B57?style=for-the-badge)
![Checkov](https://img.shields.io/badge/Checkov-Policy%20as%20Code-DC143C?style=for-the-badge)
![Encryption](https://img.shields.io/badge/Encryption-KMS%20Enabled-28A745?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-CI%20Green-00C851?style=for-the-badge)

**An enterprise-grade DevSecOps CI/CD security enforcement pipeline built on AWS Free Tier**  
**Infrastructure as Code | Security-First CI/CD | Automated Policy Enforcement | Zero Manual Console Configuration**
</div>

---

# Table of Contents

- [About This Project](#about-this-project)
- [Architecture](#architecture)
- [Architecture Decisions & Rationale](#architecture-decisions--rationale)
- [Security Controls Implemented](#security-controls-implemented)
- [CI/CD Security Enforcement](#cicd-security-enforcement)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Screenshots](#deployment-screenshots)
- [Governance Strategy](#governance-strategy)
- [Destroy Infrastructure](#destroy-infrastructure)
- [Author](#author)
- [License](#license)

---

# About This Project  
**DevSecOps Engineer Perspective**

SecureFlow was designed and implemented from the perspective of a **DevSecOps Engineer responsible for enforcing security gates before infrastructure reaches production**.

This is not simply Terraform deployment.  
This project demonstrates:

- Shift-left security enforcement
- Automated CI/CD pipeline validation
- Infrastructure-as-Code security scanning
- Risk-based policy governance
- AWS hardening best practices
- Audit logging architecture

Everything is provisioned via Terraform.  
Every push to GitHub triggers security validation.  
No manual AWS console configuration was performed.

---

## The Problem This Solves

Many organizations deploying infrastructure via Terraform face these challenges:

1. **Insecure IaC reaches production** — No automated security scanning
2. **Compliance drift** — No validation of encryption, logging, or access controls
3. **Manual review bottlenecks** — Security reviews delay deployment cycles
4. **Lack of governance visibility** — No documented enforcement strategy

SecureFlow solves these by embedding security directly into the CI/CD pipeline.

---

## My Role on This Project

| Responsibility | Detail |
|----------------|--------|
| DevSecOps Architecture | Designed CI/CD security enforcement workflow |
| Infrastructure as Code | Authored Terraform resources for AWS security hardening |
| CI/CD Pipeline Design | Built GitHub Actions workflow with security gates |
| Encryption Strategy | Implemented KMS-based encryption across resources |
| Audit Logging | Architected multi-region CloudTrail with validation |
| Governance Enforcement | Integrated tfsec and Checkov with scoped policy tuning |
| IAM Security | Designed least-privilege CloudTrail → CloudWatch role |

---

# Architecture

<img width="700" height="400" alt="Architecture" src="https://github.com/user-attachments/assets/f95a54c0-628d-4040-a06d-26c043ee3656" />


This architecture simulates how modern enterprises enforce security before infrastructure deployment.

---

# Architecture Decisions & Rationale

### Why integrate tfsec in CI/CD?
Manual Terraform review does not scale.  
tfsec blocks insecure IaC before it merges into main.

### Why integrate Checkov with scoped enforcement?
Not all enterprise policies apply to Free Tier demo environments.  
Security governance requires **risk-based enforcement**, not checkbox compliance.

### Why Multi-Region CloudTrail?
Attackers often operate in unused regions.  
Multi-region logging eliminates blind spots.

### Why KMS CMK instead of default encryption?
Customer Managed Keys allow:
- Explicit key policies
- Rotation control
- Access governance
- Audit visibility

### Why enable Log File Validation?
Prevents tampering of CloudTrail logs.  
Provides cryptographic integrity verification.

---

# Security Controls Implemented

## Defence-in-Depth Matrix

| Layer | Control | AWS Service | Status |
|--------|----------|-------------|--------|
| Identity | Least Privilege Role | IAM | Enforced |
| Data | Encryption at Rest | KMS CMK | Enabled |
| Data | Versioning | S3 | Enabled |
| Network | Public Access Block | S3 |  Enabled |
| Audit | API Logging | CloudTrail | Multi-region |
| Audit | Log Validation | CloudTrail |  Enabled |
| Audit | Centralized Logs | CloudWatch |  Integrated |
| CI/CD | IaC Security Scan | tfsec |  Passed |
| CI/CD | Policy Scan | Checkov |  Scoped Enforcement |
| CI/CD | Format Validation | Terraform fmt |  Enforced |

---

# CI/CD Security Enforcement

Pipeline Name:
```
Secure DevSecOps Pipeline
```

Trigger:
```
On push to main branch
```

### Enforcement Stages

1. ✅ Terraform Initialization  
2. ✅ Terraform Format Enforcement  
3. ✅ Terraform Validation  
4. ✅ tfsec Scan (Blocks HIGH findings)  
5. ✅ Checkov Policy Scan (Soft fail with scoped rules)

Pipeline Status:
✅ Green (All stages passed)

---

# Project Structure

```
secureflow-devsecops/
│
├── .github/
│   └── workflows/
│       └── secure-pipeline.yml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
│
├── docs/
│   └── screenshots/
│       ├── 01-github-actions-pipeline-green.png
│       ├── 02-s3-bucket-encrypted-versioned.png
│       ├── 03-cloudtrail-secure-config.png
│       └── 04-terminal-terraform-apply-success.png
│
├── .gitignore
└── README.md
```

---

# Prerequisites

| Tool | Minimum Version |
|------|-----------------|
| Terraform | >= 1.3 |
| AWS CLI | >= 2.0 |
| Git | Any |
| AWS Account | Free Tier Compatible |

Required IAM permissions include:
```
s3:*, cloudtrail:*, kms:*, logs:*, iam:*
```

---

# Quick Start

### Clone Repository

```bash
git clone https://github.com/AdeoyeEmmanuel2020/secureflow-devsecops.git
cd secureflow-devsecops
```

### Configure AWS

```bash
aws configure
```

### Deploy Infrastructure

```bash
terraform -chdir=terraform init
terraform -chdir=terraform apply
```

---

# Deployment Screenshots

## 1️⃣ GitHub Actions Pipeline — Green

**Proof:**
- github-actions-pipeline-green
- tfsec passed
- Checkov ran
- All steps successful

![Pipeline](docs/screenshots/01-github-actions-pipeline-green.png)

---

## 2️⃣ Secure S3 Bucket

Bucket:
```
secureflow-f587ea6f
```

Captured:
- Encryption Enabled (AES-256)
- Versioning Enabled
- Tags applied
- Public access blocked

![S3](docs/screenshots/02-s3-bucket-encrypted-versioned.png)

---

## 3️⃣ CloudTrail Configuration

Captured:
- Trail name: secureflow-trail
- Status: Logging enabled
- Multi-region: Enabled
- AWSCloudTrailWrite policy
- Log validation enabled

![CloudTrail](docs/screenshots/03-cloudtrail-secure-config.png)

---

## 4️⃣ Terraform Apply Output

Captured:
- Terraform Apply Output
- Resources created
- No errors

![Terraform](docs/screenshots/04-terminal-terraform-apply-success.png)

---

# Governance Strategy

This project demonstrates risk-based DevSecOps governance:

- High-risk findings blocked via tfsec
- Non-critical enterprise controls scoped via Checkov
- CI/CD fails fast on insecure configuration
- Encryption and logging enforced by design

This mirrors real enterprise DevSecOps implementation patterns.

---

# Destroy Infrastructure

```bash
terraform -chdir=terraform destroy -auto-approve
```

Always destroy Free Tier resources when finished to avoid charges.

---

# Author

**Adeoye Emmanuel**  
AWS Certified Solutions Architect | DevSecOps Engineer  

LinkedIn: https://www.linkedin.com/in/emmanuel-adeoye-29187bb7  
GitHub: https://github.com/AdeoyeEmmanuel2020  

---

# License

MIT License

Copyright (c) 2025 Adeoye Emmanuel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files to deal in the Software
without restriction.
