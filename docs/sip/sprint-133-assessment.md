# AWS SIP Sprint 133 assessment

This assessment supports the AI delivery POC in [modernisation-platform issue #13592](https://github.com/ministryofjustice/modernisation-platform/issues/13592). It routes each Sprint 133 SIP issue to the existing owner of the affected resource lifecycle.

It is based on issue bodies and repository source inspection. It does not claim to verify deployed AWS state.

## Summary

| Readiness | Issues |
| --- | --- |
| Decision required | 86, 105, 119, 121, 124, 126, 127, 129, 130 |
| AWS evidence required | 87, 88, 120, 125 |
| Partially implemented | 86, 119, 123, 127 |
| Potentially complete | 128 |
| Investigation only | 89, 106, 109, 110, 111, 137, 138 |

Some issues appear in more than one row because readiness and current implementation are separate dimensions. A partially implemented issue can still require a decision before further code is safe.

## Routing matrix

| Issue | Primary route | Owning repository or area | Next action |
| --- | --- | --- | --- |
| 86 | Operational automation | `modernisation-platform/scripts/iam-monitoring` | Agree key populations, rotation age and enforcement behaviour before extending the live hygiene workflow. |
| 87 | Delegated security service | Live AWS, then the repository owning each finding | Review Access Analyzer findings in MP-owned accounts before proposing remediation. |
| 88 | Workload or module | Baselines, MP IAM code and affected modules | Generate policies from observed access, then review each reduction independently. |
| 89 | Investigation | MP IAM and ECR implementations | Inventory existing ABAC and identify a bounded test candidate. |
| 105 | Organization policy or account baseline | `aws-root-account` for prevention; baselines for detection | Decide prevention versus detection and define service-user exceptions. |
| 106 | Network security | `modernisation-platform/terraform/environments/core-network-services` | Assess rule compatibility, cost and a representative non-production test. |
| 109 | Operational automation | New isolated MP automation and runbook | Build a non-production containment POC only after recovery and authorization are defined. |
| 110 | Account baseline | `modernisation-platform-terraform-baselines` | Run a cost-bounded, opt-in CloudTrail Insights experiment in one approved test account. |
| 111 | Delegated security service | `aws-root-account` | Refine the ticket because its title says Inspector while its narrative says Detective. |
| 119 | Account baseline | Baselines implementation plus MP consumer pin | Resolve notification, scope and automation-role decisions, then implement the default-off POC. |
| 120 | Operational automation | Live AWS inventory, then a reusable reporting workflow | Define owner tags, age threshold and review process before considering deletion. |
| 121 | Organization policy | `aws-root-account/management-account/terraform` | Identify critical log groups and exception principals before drafting an unattached policy. |
| 123 | Central logging | `modernisation-platform/terraform/environments/core-logging` | Compare existing partition-projected CloudTrail Athena support with the service-log scope and add only missing coverage or documentation. |
| 124 | Organization policy | `aws-root-account/management-account/terraform` | Identify critical buckets and permitted lifecycle automation before drafting an unattached policy. |
| 125 | Workload or module | Live AWS and repositories owning Lambda functions | Inventory resource policies and public access before selecting a common enforcement mechanism. |
| 126 | Central logging | Core logging plus account baselines | Resolve overlap with CloudTrail Insights and define the API metric used for real-time anomaly detection. |
| 127 | Central logging | Core logging plus account baselines | Correct the scope conflict between core and member accounts and assess existing forwarding before implementation. |
| 128 | Account baseline | `modernisation-platform-terraform-baselines` | Verify the existing sign-in failure filter, threshold and notification route in the intended accounts. |
| 129 | Operational automation | New reporting-first workflow | Agree inactivity, ownership and exclusions; do not include automatic termination in the initial POC. |
| 130 | Organization policy or detection | Root account and/or baselines | Establish whether prevention is expressible safely; otherwise prefer detection and review. |
| 137 | Workload or module | Lambda and ECR module owners | Select one MP-owned artifact and assess signing support and pipeline impact. |
| 138 | Delegated security service | `aws-root-account` management and organisation-security stacks | Test audit-only Firewall Manager policy design before any remediation mode. |

## POC change set

SIP issue 119 is the implementation example because the baseline module already has the required CloudTrail, alarm, notification and automation-exclusion components.

1. Add a default-off CreateUser filter and alarm to `modernisation-platform-terraform-baselines`.
2. Add module tests proving disabled and enabled behaviour.
3. Release the module after review.
4. Update the two baseline pins in `modernisation-platform`.
5. Select and enable only one MP-approved development or test workspace in the implementation PR.
6. Review the Terraform plan before deployment.
7. Verify matching and excluded CloudTrail events and notification delivery.

The detailed assessment is in `docs/sip/119-assessment.yaml`, and the proposed Terraform change is in `docs/sip/119-proposed-change.md`.

## Completion evidence for issue 13592

- A reusable agent workflow defines the assessment, routing, safety and handoff process.
- An ownership map routes controls to existing repository owners.
- A schema makes ticket outputs consistent and machine-checkable.
- All 22 Sprint 133 issues have an initial route and next action.
- SIP issue 119 has a concrete, ordered multi-repository implementation proposal.

The POC remains at the `suggested` completion level until code and tests are added in the baseline repository. It must not be described as implemented, validated or verified before those steps occur.
