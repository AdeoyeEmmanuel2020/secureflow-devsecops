# Architecture and Assurance Case

## Purpose

This document explains how SecureFlow converts an audit-resilience objective into an implementable AWS design. It records the system boundary, trust assumptions, data flows, decisions, failure modes, and verification strategy.

## Quality attributes

1. **Integrity** - material alteration of audit evidence should be detectable.
2. **Confidentiality** - evidence should be encrypted in transit and at rest.
3. **Availability** - regional activity should remain observable and logs retained for investigation.
4. **Accountability** - configuration changes and API actions should be attributable.
5. **Reproducibility** - a clean environment should produce the same logical control set.
6. **Auditability** - each claim should map to code and an evidence-producing test.

## System boundary and trust zones

| Zone | Components | Trust assumption |
|---|---|---|
| Development | Engineer workstation and Git client | Endpoint and developer identity are managed |
| Source control | GitHub, reviews, branch rules, Actions | Governance prevents unilateral unreviewed merge |
| Deployment | Terraform process and AWS identity | Deployment principal is short-lived and least-privileged |
| Workload account | KMS, S3, CloudTrail, CloudWatch Logs, IAM | AWS service contracts operate as documented |
| Evidence consumers | Security operations, audit, incident response | Read access is authorised, logged, and reviewed |

The repository does not implement organisational identity governance, GitHub branch protection, AWS Organizations, central security accounts, or a remote Terraform backend. They are external dependencies, not implicit guarantees.

## Data flow

1. An engineer proposes Terraform changes through a pull request.
2. GitHub Actions evaluates syntax, formatting, and configuration-policy rules.
3. An authorised operator reviews the plan and applies it from a controlled context.
4. CloudTrail records AWS API activity across Regions and global services.
5. CloudTrail encrypts and writes digest-protected evidence to S3 and streams events to CloudWatch Logs.
6. Security personnel query retained evidence during detection, investigation, and audit.

## Architecture decisions

### ADR-001: Terraform is authoritative

Cloud controls are declared in Terraform and console changes are treated as drift. Version control improves reviewability, repeatability, traceability, and rollback planning. The trade-off is that state becomes sensitive and operationally critical; production requires encrypted remote state, locking, restricted access, and recovery testing.

### ADR-002: A customer-managed KMS key protects the evidence path

A customer-managed key provides auditable policy, lifecycle control, rotation, and service-specific permissions. Incorrect policy or scheduled deletion can interrupt delivery, so production requires monitoring and separation of key administration from key use.

### ADR-003: CloudTrail is multi-Region and validates logs

Regional coverage, global-service events, and digest validation reduce geographic blind spots and make alteration detectable. They increase cost and do not prevent every deletion or availability failure.

### ADR-004: CI fails closed for material findings

Formatting, validation, high/critical Trivy findings, and Checkov findings block the workflow. False positives can delay delivery, so exceptions require documented risk acceptance rather than broad suppression.

### ADR-005: CI validates but does not deploy

Deployment requires account-specific identity, approvals, environment protection, and rollback controls that cannot be safely generalised. The reference workflow therefore avoids automatic apply.

## Failure modes

| Failure mode | Effect | Detection | Response |
|---|---|---|---|
| CloudTrail delivery failure | Lost or delayed evidence | Trail status and delivery-error monitoring | Alert, preserve alternate evidence, restore policy/key access |
| KMS disabled or scheduled for deletion | Encryption and delivery failure | KMS events and key-state alarm | Cancel deletion, re-enable under dual control, investigate |
| Bucket policy weakened | Exposure or overwrite risk | PR gate and future AWS Config rule | Block merge or remediate drift |
| CI bypassed | Unreviewed configuration | Branch/ruleset audit log | Investigate exception and affected changes |
| Scanner compromise | False assurance or code execution | Pinning, provenance review, Dependabot | Disable dependency and review affected runs |
| State loss or disclosure | Recovery difficulty or metadata leak | Backend access monitoring | Restore versioned state and reconcile resources |

## Assurance levels

- **L1 - Static:** formatting, Terraform validation, and configuration scanners pass.
- **L2 - Plan:** a reviewed plan contains only intended changes.
- **L3 - Runtime:** AWS APIs confirm deployed state and negative tests are denied.
- **L4 - Operational:** alerts, recovery, key lifecycle, and evidence retrieval are exercised.

This repository automates L1 and supports L2-L3. L4 requires organisational processes and independent evidence.

## Production evolution

The target state uses a dedicated log-archive account, organisation trail, delegated security administration, S3 Object Lock where appropriate, OIDC deployment, remote state with locking, policy unit tests, signed artefacts, drift detection, alerting, and scheduled recovery exercises.
