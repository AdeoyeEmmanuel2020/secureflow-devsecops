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
