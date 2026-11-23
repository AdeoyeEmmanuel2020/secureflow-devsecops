# Security Control and Evidence Matrix

Framework references support engineering traceability only; they do not establish certification.

| Objective | Threats | Implementation | Evidence | Reference examples | Next step |
|---|---|---|---|---|---|
| Prevent public exposure | T4 | Public-access blocks and TLS-only policies | Plan, API result, negative request | CIS AWS; NIST PR.DS | Add SCP and Config rule |
| Protect data at rest | T2, T4 | KMS rotation; S3/CloudWatch encryption | Key and encryption APIs | NIST PR.DS; ISO 27001 | Separate key administrators/users |
| Preserve audit integrity | T2, T3 | Log validation and S3 versioning | Digest validation; version listing | NIST DE.CM; SOC 2 CC7 | Add Object Lock/archive account |
| Capture regional activity | T3 | Multi-Region trail and global events | Trail config and test event | CIS AWS logging | Upgrade to organisation trail |
| Restrict service access | T4, T6 | Service principal, source conditions, scoped paths | Policy review/simulation | NIST PR.AA | Periodic access review |
| Reject insecure IaC | T1, T8 | Required workflow, Terraform, Trivy, Checkov | Workflow and branch-rule export | NIST PR.IP; SOC 2 CC8 | Pin actions to reviewed SHAs |
| Support reproducibility | T8 | Version constraints, lock file, commands | Clean-run validation | SLSA concepts | Hermetic toolchain |
| Support recovery | T2, T5 | Versioning and delayed key deletion | Recovery exercise | NIST RC.RP | Formal runbooks and RTO/RPO |

## Exception record schema

Every exception records the control/rule, resource and environment, rationale, threat and impact, compensating control, owner, approval date, expiry date, and review evidence. Inline suppressions without this record are not acceptable governance.

## Current reference-architecture exceptions

| Check | Rationale | Compensating treatment | Review trigger |
|---|---|---|---|
| CKV_AWS_109, CKV_AWS_111, CKV_AWS_356 | KMS key policies require an account-root administrative statement and service actions represented with `*`; use is bounded by the key, service principal, source ARN, account, and encryption context | Explicit key-policy review and production separation of key administrators from users | KMS policy or identity model changes |
| CKV_AWS_144 | Cross-Region S3 replication requires a second-region destination and role outside this single-account research boundary | Multi-Region event capture, versioning, and a documented archive-account target state | Production or resilience-scope adoption |
| CKV_AWS_145 | The S3 server-access-log destination uses SSE-S3 because this delivery path is not modelled with a customer-managed key; primary CloudTrail evidence uses the CMK | Restricted delivery policy, TLS-only access, public-access block, and versioning | Logging architecture changes |
| CKV2_AWS_62 | No downstream S3 event consumer is inside the current boundary | CloudTrail-to-CloudWatch delivery and SNS trail notifications provide operational signals | Event-driven detection is added |

These identifiers are explicitly scoped in CI. Expansion requires an updated threat model, accountable owner, rationale, compensating treatment, and review trigger.
