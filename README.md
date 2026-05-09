# SecureFlow — Enterprise DevSecOps CI/CD Security Pipeline on AWS

> A production-grade DevSecOps security enforcement pipeline built entirely with Terraform and GitHub Actions.
> Demonstrates Infrastructure-as-Code hardening, automated security scanning,
> encryption governance, centralized logging, and CI/CD policy enforcement.

![Terraform](https://img.shields.io/badge/Terraform-v1.5%2B-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![Security](https://img.shields.io/badge/Security-Shift--Left-3fb950)
![tfsec](https://img.shields.io/badge/IaC%20Scan-tfsec-2E8B57)
![Checkov](https://img.shields.io/badge/Policy%20Scan-Checkov-DC143C)
![Encryption](https://img.shields.io/badge/KMS-Enabled-28A745)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## Table of Contents

- [About This Project](#about-this-project)
- [Architecture](#architecture)
- [Architecture Decisions and Rationale](#architecture-decisions-and-rationale)
- [Security Controls Implemented](#security-controls-implemented)
- [CI/CD Security Enforcement](#cicd-security-enforcement)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Module Documentation](#module-documentation)
- [Compliance Alignment](#compliance-alignment)
- [Deployed Infrastructure — Live Resource IDs](#deployed-infrastructure--live-resource-ids)
- [Terminal Evidence](#terminal-evidence)
- [AWS Console Evidence](#aws-console-evidence)
- [GitHub Actions Pipeline](#GitHub-Actions-Pipeline)
- [Destroy Infrastructure](#destroy-infrastructure)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

---

## About This Project

This project provisions a fully hardened AWS security logging and encryption foundation using Terraform — enforced by an automated DevSecOps CI/CD pipeline.

Every security decision is intentional and documented.

**What makes this different from a typical cloud project:**

- Infrastructure cannot reach production without passing tfsec and Checkov.
- Encryption is enforced via Customer Managed KMS keys.
- CloudTrail is multi-region with log file validation enabled.
- S3 buckets enforce versioning, encryption, and public access blocking.
- IAM policies follow least privilege principles.
- CI/CD pipeline blocks insecure Infrastructure-as-Code before merge.
- All configuration is written in Terraform — no manual AWS console setup.

**Technologies used:**
Terraform, GitHub Actions, AWS KMS, AWS S3, AWS CloudTrail, AWS CloudWatch,
AWS IAM, tfsec, Checkov, Git, AWS CLI.

---

## Architecture

<img width="700" height="400" alt="Architecture" src="https://github.com/user-attachments/assets/ff17e339-7282-4fe1-8f55-023995e4949c" />

---

## Architecture Decisions and Rationale

### Why integrate tfsec in CI/CD?

Manual code review is inconsistent and error-prone.  
tfsec blocks insecure Terraform configurations (e.g., unencrypted storage, open security groups) before they are merged into main.

This shifts security left in the development lifecycle.

---

### Why use Checkov with scoped enforcement?

Enterprise compliance tools often include controls irrelevant to small-scoped environments.

Instead of blindly enforcing every policy, this project demonstrates:

- Risk-based governance
- Scoped policy enforcement
- Soft-fail on non-critical controls
- Hard-fail on high-risk misconfigurations

This mirrors real-world DevSecOps governance strategy.

---

### Why Multi-Region CloudTrail?

Attackers frequently create resources in unused AWS regions to avoid detection.

Enabling multi-region logging ensures:

- No regional blind spots
- Full API activity capture
- Improved forensic visibility

---

### Why enable Log File Validation?

CloudTrail log validation creates hash digests for log files.

If a log file is altered, the validation check fails.

This ensures:

- Tamper detection
- Forensic integrity
- Audit reliability

---

### Why use a Customer Managed KMS Key instead of AWS Managed Keys?

Customer Managed Keys allow:

- Custom key policies
- Rotation enforcement
- Principal-level access control
- Explicit audit visibility

AWS managed keys do not provide equivalent granular governance control.

---

## Security Controls Implemented

| # | Control | Layer | Implementation | What It Prevents |
|---|----------|--------|----------------|-----------------|
| 1 | Encryption at Rest | Data | KMS CMK | Plaintext data exposure |
| 2 | S3 Versioning | Data | Enabled | Log tampering |
| 3 | Public Access Block | Network | All 4 blocks enabled | Public bucket exposure |
| 4 | Least Privilege IAM | Identity | Scoped policies | Privilege escalation |
| 5 | CloudTrail Multi-Region | Audit | is_multi_region_trail = true | Regional blind spots |
| 6 | Log File Validation | Audit | enable_log_file_validation = true | Log tampering |
| 7 | CloudWatch Integration | Monitoring | Log group + role | Delayed detection |
| 8 | IaC Security Scan | CI/CD | tfsec | Insecure Terraform |
| 9 | Policy Enforcement | CI/CD | Checkov | Compliance drift |
| 10 | Terraform Validation | CI/CD | terraform validate | Broken configuration |
| 11 | Format Enforcement | CI/CD | terraform fmt | Inconsistent code quality |

---

## CI/CD Security Enforcement

Pipeline Name:
```
Secure DevSecOps Pipeline
```

Trigger:
```
On push to main branch
```

Stages:

1. Terraform Init  
2. Terraform Format  
3. Terraform Validate  
4. tfsec Scan (Blocks HIGH findings)  
5. Checkov Scan (Scoped Governance)

Pipeline Status:
All stages passed (Green)

---

## Project Structure

```bash
secureflow-devsecops/
│
├── providers.tf                # AWS provider configuration
├── main.tf                     # Core infrastructure (KMS, S3, CloudTrail, IAM)
├── variables.tf                # Input variable definitions
├── outputs.tf                  # Resource outputs
├── .gitignore                  # Excludes state files and secrets
├── README.md                   # This documentation
│
├── .github/
│   └── workflows/
│       └── secure-pipeline.yml # CI/CD security pipeline
│
└── screenshots/
    ├── 01-github-actions-pipeline-green.png
    ├── 02-s3-bucket-encrypted-versioned.png
    ├── 03-cloudtrail-secure-config.png
    └── 04-terminal-terraform-apply-success.png
```

---

## Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Terraform | 1.5.0 |
| AWS CLI | 2.0 |
| Git | Any |
| GitHub Account | Required |
| AWS Account | Required |

Verify installation:

```bash
terraform version
aws --version
git --version
aws sts get-caller-identity
```

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/AdeoyeEmmanuel2020/secureflow-devsecops.git
cd secureflow-devsecops

# Configure AWS credentials
aws configure

# Initialise Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan -out=tfplan

# Deploy
terraform apply tfplan

# View outputs
terraform output
```

---

## Module Documentation

### `main.tf`

Creates:

- `aws_kms_key` — Customer Managed Key with rotation
- `aws_s3_bucket` — Secure bucket for logs
- `aws_s3_bucket_public_access_block` — Blocks public exposure
- `aws_s3_bucket_versioning` — Enables object versioning
- `aws_cloudtrail` — Multi-region audit logging
- `aws_cloudwatch_log_group` — Centralized logs
- `aws_iam_role` — Least privilege role
- `aws_iam_role_policy` — Scoped CloudWatch permissions

Key Outputs:

- `bucket_name`
- `cloudtrail_name`
- `kms_key_arn`

---

## Compliance Alignment

| Control Domain | Implementation | Standard Reference |
|---------------|----------------|-------------------|
| Encryption | KMS CMK | CIS AWS 2.2 |
| Audit Logging | CloudTrail multi-region | CIS AWS 3.x |
| Log Validation | enable_log_file_validation | SOC2 CC7.2 |
| Access Control | IAM least privilege | CIS AWS 1.16 |
| Change Management | Terraform only | SOC2 CC8.1 |
| Monitoring | CloudWatch integration | ISO 27001 A.12.4 |
| Shift-Left Security | tfsec + Checkov | DevSecOps best practice |

---

## Deployed Infrastructure — Live Resource IDs

Example output from `terraform output`:

```
bucket_name = "secureflow-f587ea6f"
cloudtrail_name = "secureflow-trail"
kms_key_arn = "arn:aws:kms:us-east-1:XXXXXXXXXXXX:key/xxxxxxxx-xxxx"
```

---

## Terminal Evidence

### 01 — Terraform Apply Output
<img width="700" height="400" alt="Terraform Apply Output" src="https://github.com/user-attachments/assets/c30d8a63-e992-463f-b115-16fc0f9a2506" />

---

## AWS Console Evidence

### 02 — S3 Bucket
<img width="700" height="400" alt="S3 bucket" src="https://github.com/user-attachments/assets/6f3dd567-a5be-4ec1-b0f6-11ea9730623c" />

---
### 03 - Versioning Enabled
<img width="700" height="400" alt="Versioning Enabled" src="https://github.com/user-attachments/assets/cd6d1b40-36ab-4957-ad19-052afbca69a6" />

------
### 04 - Multi-region
<img width="700" height="400" alt="Multi-region" src="https://github.com/user-attachments/assets/d43130a6-403e-46e9-9734-d9ae952b5c08" />

------
### 05 - Encryption Enabled (AES-256)
<img width="700" height="400" alt="Encryption Enabled (AES-256)" src="https://github.com/user-attachments/assets/6026eeb5-d12f-4539-9135-ab4b3233b407" />

---------
### 06 - Tags
<img width="700" height="400" alt="Tags" src="https://github.com/user-attachments/assets/ae54164d-f680-4b4a-bc31-ed381b5922c6" />

---------

### 07 — CloudTrail Configuration

<img width="700" height="400" alt="Trail name" src="https://github.com/user-attachments/assets/e67c396c-fb4a-40ef-bc95-336739c4888d" />

---
### 07 — Status Logging enabled
<img width="700" height="400" alt="Status Logging enabled" src="https://github.com/user-attachments/assets/bc2a529a-3ba7-4193-a21e-89ae6a49b5f8" />

----

### 08 — AWS Cloud Trail Write policy

<img width="700" height="400" alt="AWSCloudTrailWrite" src="https://github.com/user-attachments/assets/3008cade-9b86-4125-8444-095e7becee7f" />

------

### 09 — GitHub Actions Pipeline
<img width="700" height="400" alt="github-actions-pipeline-green" src="https://github.com/user-attachments/assets/68518015-9d3b-4c40-8ab9-872d92b2f0db" />


------
### 10 — tfsec passed
<img width="700" height="400" alt="tfsec passed" src="https://github.com/user-attachments/assets/e12c756a-078d-452f-9908-152fe7afdaa1" />

-----
### 11 — Checkov ran
<img width="700" height="400" alt="Checkov ran" src="https://github.com/user-attachments/assets/ff87ad8e-0a03-4474-8367-9b5814b94e75" />

-----

## Destroy Infrastructure

```bash
terraform destroy -auto-approve
```

This removes all resources and avoids ongoing charges.

---

## Contributing

1. Fork repository
2. Create feature branch
3. Run:
   ```bash
   terraform fmt -recursive
   terraform validate
   ```
4. Submit Pull Request

---

# Author

**Adeoye Emmanuel**  
AWS Certified Solutions Architect | DevSecOps Engineer  

Email: Emmanuelofgrace@gmail.com  
LinkedIn: www.linkedin.com/in/emmanuel-adeoye-29187bb7  

---

# License

MIT License

Copyright (c) 2025 Adeoye Emmanuel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files to deal in the Software
without restriction.
