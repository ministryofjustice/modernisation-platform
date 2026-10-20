# 44. S3 Delete Protection: Object Lock Replicas over MFA Delete

Date: 2026-06-09

## Status

✅ Accepted

## Context

As part of hardening S3 buckets containing critical security logs (including API activity and CloudTrail data), we evaluated MFA Delete as a protective control against accidental or malicious object deletion.

MFA Delete is an S3 feature that requires a valid MFA token to be presented when permanently deleting a versioned object or suspending versioning on a bucket. While it provides an additional authentication barrier, investigation revealed a number of practical constraints that make it unsuitable as our primary deletion protection mechanism in this organisation.

Key findings from evaluation:

- MFA Delete can only be enabled or disabled by the **bucket-owning account's root user**. IAM roles, including `OrganizationAccountAccessRole`, cannot perform this action regardless of permission grants. This creates an operational dependency on root user access across every member account.
- Root user access must be managed individually per account. In an AWS Organizations setup this introduces significant operational overhead: each account requires an enrolled root MFA device, secure credential storage, and a documented access procedure.
- MFA Delete applies only to the **source bucket**. It does not extend to any replica or backup destination.
- The protection MFA Delete provides is additive friction, not immutability. A sufficiently privileged or compromised root user can still disable it and proceed with deletion.
- There is no programmatic path to enforce or audit MFA Delete status at scale via SCPs or AWS Config rules, since SCP conditions cannot target the root principal in a useful way for this purpose.

Our existing architecture already applies cross-region replication from source buckets to dedicated replica buckets. During this evaluation we confirmed those replica buckets have S3 Object Lock enabled.

## Decision

We will **not implement MFA Delete** on S3 buckets containing critical security logs. Instead, we will rely on the existing cross-region replication architecture with **S3 Object Lock (Compliance mode)** on replica buckets as the primary deletion protection control.

### Rationale

S3 Object Lock in Compliance mode provides a stronger and operationally simpler guarantee than MFA Delete:

- Object Lock in Compliance mode cannot be overridden by any principal for the duration of the retention period, including root users and AWS Support. MFA Delete can be disabled by a root user at any time.
- Object Lock is enforceable via SCP and AWS Config. MFA Delete is not.
- Object Lock does not require root user involvement to configure or maintain. It can be set at bucket creation time and managed through standard IAM-controlled API paths.
- Cross-region replication ensures that even if a source bucket object is deleted or overwritten, a protected copy is retained in the replica bucket for the full retention window.
- The combination of replication lag (typically sub-minute) and a defined retention period means the window of unprotected exposure on the source is negligible for the threat model we are addressing.

### Object Lock mode requirement

Replica buckets **must** use **Compliance mode**, not Governance mode. Governance mode can be overridden by principals with the `s3:BypassGovernanceRetention` permission, which weakens the immutability guarantee. This should be verified across all replica buckets.

### Verification

```bash
# Confirm Object Lock configuration on replica bucket
aws s3api get-object-lock-configuration --bucket <REPLICA_BUCKET_NAME>
```

Expected output for a correctly configured bucket:

```json
{
    "ObjectLockConfiguration": {
        "ObjectLockEnabled": "Enabled",
        "Rule": {
            "DefaultRetention": {
                "Mode": "COMPLIANCE",
                "Days": <RETENTION_DAYS>
            }
        }
    }
}
```

If any replica bucket returns `"Mode": "GOVERNANCE"` or has no default retention rule set, it must be remediated before this decision is considered fully implemented.

## Scope and constraints

- This decision applies to S3 buckets designated as critical security log stores, including API activity logs and CloudTrail data.
- Source buckets are not covered by Object Lock directly. The source bucket's versioning and lifecycle policies should be reviewed separately to ensure version accumulation does not create unexpected cost or compliance gaps.
- This decision does not preclude applying MFA Delete in future if a specific compliance framework explicitly mandates it and the operational overhead is accepted at that time.

## Complementary controls

The following controls are in place or recommended alongside Object Lock replication:

- S3 Versioning enabled on source buckets.
- S3 Block Public Access enabled on all relevant buckets.
- CloudTrail data event logging for `s3:DeleteObject` and `s3:DeleteObjectVersion` on source buckets, with alerting via EventBridge.
- KMS encryption enforced on source and replica buckets, consistent with the approach documented in ADR-43.
- Bucket policies restricting deletion actions to narrowly scoped, audited principals on the source bucket.

## Consequences

### Positive

- Stronger immutability guarantee than MFA Delete for retained log data.
- No dependency on root user access or root MFA device management at scale.
- Consistent with existing replication architecture; no new infrastructure required.
- Auditable and enforceable via standard AWS policy controls.

### Trade-offs and risks

- Protection is on the **replica**, not the source. A deletion on the source is not prevented; it is recoverable.
- Replication continuity must be monitored. If replication fails silently, the protection guarantee degrades. CloudWatch metrics for replication lag and failure events should be in place.
- Retention period selection is important. Too short a period reduces the recovery window; too long increases storage cost and may complicate legitimate data lifecycle operations.

### Follow-up actions

1. Audit all replica buckets to confirm Object Lock is in Compliance mode with an appropriate retention period configured.
2. Confirm replication health monitoring is in place via CloudWatch and alerting pipelines.
3. Document the approved retention period for each bucket class and record this alongside the bucket tagging strategy.
4. Review source bucket deletion permissions and apply least-privilege bucket policies where not already in place.
