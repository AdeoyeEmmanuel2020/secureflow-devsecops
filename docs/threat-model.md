# Threat Model

## Method

This model combines asset-centric analysis with STRIDE. It is a living engineering artefact, not a one-time compliance document. Threats are prioritised qualitatively because this reference has no organisation-specific loss data.

## Protected assets

- CloudTrail records and digest files
- KMS key material and policy
- Terraform source, state, and plans
- GitHub workflows and branch rules
- AWS deployment and GitHub identities
- Security findings and pipeline evidence

## Adversaries

- External attacker using stolen credentials
- Malicious or coerced insider
- Compromised dependency or GitHub Action
- Over-privileged automation identity
- Engineer introducing unsafe configuration unintentionally

## Abuse cases

| ID | STRIDE | Scenario | Existing treatment | Residual risk |
|---|---|---|---|---|
| T1 | Spoofing | Stolen developer identity submits a change | Review and required CI are expected controls | Administrator or reviewer compromise |
| T2 | Tampering | Actor alters audit objects | Versioning, KMS, TLS-only policy, log validation | Same-account deletion; Object Lock absent |
| T3 | Repudiation | Actor denies a privileged AWS change | Multi-Region CloudTrail | Logging can fail before delivery |
| T4 | Disclosure | Logs become public or improperly readable | Public-access blocks, scoped policy, KMS | Identity policies outside this stack |
| T5 | Denial of service | KMS is disabled or blocks CloudTrail | Lifecycle controls and monitoring requirement | No automated remediation in scope |
| T6 | Elevation | CI/Terraform identity gains excess privilege | No deployment credentials in reference CI | Implementer may create an over-broad role |
| T7 | Supply chain | Compromised action executes in CI | Versioned dependencies and Dependabot | Tags are not immutable SHAs |
| T8 | Policy bypass | Soft fail or suppression hides weakness | Hard-fail gates; no broad skip list | False negatives and incomplete rulesets |

## Assumptions

1. Branch rules require successful checks and independent review.
2. AWS root is protected and not used operationally.
3. Deployment uses short-lived credentials from an authorised environment.
4. Terraform state is secured outside this repository.
5. AWS service availability and time synchronisation support event correlation.

If an assumption is false, revise the assurance argument rather than silently retaining it.

## Validation experiments

| Experiment | Expected result |
|---|---|
| Remove S3 public-access block in a pull request | Policy workflow fails |
| Remove KMS encryption | Static analysis fails |
| Send unauthenticated request to bucket | Access denied |
| Send non-TLS S3 request | Explicit deny |
| Create API event in another Region | Event appears in trail |
| Validate delivered CloudTrail log | Digest chain verifies |
| Disable KMS key in sandbox | Failure is observable and runbook starts |

Review after a material architecture or identity change, incident, major dependency update, new obligation, or at least annually.
