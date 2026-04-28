# 43. Enforce S3 KMS Encryption with SCP Guardrails

Date: 2026-04-27

## Status

🤔 Proposed

## Context

We want stronger, organisation-wide controls for S3 encryption to reduce the risk of weak encryption settings across member accounts.

Recent implementation and test work in the root account policy repository showed:

- account-level IAM controls were not consistently effective across all principals and paths
- newly created S3 buckets default to SSE-S3 (AES256)
- deleting bucket encryption does not produce an unencrypted bucket state; it reverts to SSE-S3 behaviour
- object upload conditions on `s3:PutObject` are reliable
- bucket encryption condition handling through `s3:PutEncryptionConfiguration` is more nuanced and was the least reliable area during early iterations

Important platform assumption:

- Since November 2023, S3 applies default encryption to all buckets. Calling `DeleteBucketEncryption` does not remove encryption; it resets behaviour to SSE-S3 (AES256). In practice, this means buckets cannot be left with zero encryption.

We also confirmed IAM action naming details important for policy correctness:

- `s3:PutEncryptionConfiguration` is the relevant action for bucket encryption configuration updates
- `s3:PutBucketEncryption` and `s3:DeleteBucketEncryption` are not valid IAM action names in this context

This means the baseline should prioritise controls with strong, repeatable behaviour and use a phased approach for bucket-level hardening.

AWS documentation reference:

- S3 default encryption and related behaviour: https://docs.aws.amazon.com/AmazonS3/latest/userguide/blocking-unblocking-s3-c-encryption-gpb.html?icmpid=docs_amazons3_console

## Decision

We will introduce an SCP baseline to tighten S3 encryption controls for member accounts.

### Baseline controls to implement

1. Apply a bucket-level guardrail carefully:
1. Deny `s3:PutEncryptionConfiguration` when the request attempts to set bucket default encryption to `AES256`.
1. Keep object-level `s3:PutObject` encryption-deny controls as a documented option, but do not apply them broadly at OU level in the initial rollout.

### Controls deferred from initial baseline

1. Do not rely on invalid IAM action names (`s3:PutBucketEncryption`, `s3:DeleteBucketEncryption`).
1. Do not treat "delete bucket encryption" as equivalent to "unencrypted bucket", because current S3 behaviour reverts to SSE-S3.
1. Defer stricter conditions (for example mandatory KMS key ID requirements) until broader compatibility testing is complete.
1. Defer broad OU-level `s3:PutObject` deny enforcement until pilot evidence and exception handling are in place.

### Scope and rollout

1. Start with a pilot OU/account set.
1. Validate impact on existing workloads and deployment pipelines.
1. Roll out in phases to broader OUs after successful pilot.

### Enforcement intent

The initial organisation baseline will block explicit SSE-S3 usage for object writes and prevent explicitly setting bucket default encryption to SSE-S3.

The medium-term target remains stronger KMS-centric enforcement, but rollout must account for legacy workloads currently depending on SSE-S3 defaults.

## Production-safe control set

Based on current AWS API behaviour and test evidence, the production-safe control set is:

1. Primary control for initial rollout (targeted): deny `s3:PutEncryptionConfiguration` when the requested algorithm is `AES256`.
1. Optional stronger control (documented, not default): deny `s3:PutObject` when `s3:x-amz-server-side-encryption` is `AES256`.
1. Do not depend on brittle condition-key combinations for bucket encryption operations beyond tested patterns.
1. Treat SSE-C blocking as complementary hardening, not a replacement for KMS/SSE-S3 policy controls.

The initial baseline prioritises lower blast radius. The `s3:PutObject` deny remains a valid option but is intentionally not recommended for broad OU attachment until scoped pilot results confirm safe rollout.

### Operator impact clarification

An explicit deny on `s3:PutEncryptionConfiguration` only affects bucket encryption configuration updates.

By itself, it does not deny other S3 actions such as:

- `s3:PutObject`
- `s3:GetObject`
- `s3:ListBucket`

Those actions continue to depend on their own allow/deny policy evaluation and are only blocked if separately denied.

## Blast radius controls for SCP rollout

To reduce the chance of platform-wide disruption when attached as SCPs:

1. Attach first to a dedicated pilot OU with representative workloads.
1. Exclude or separately stage critical bootstrap/automation accounts used for Terraform state and shared platform operations.
1. Validate critical paths before promotion: Terraform plan/apply, state reads/writes, CI/CD object uploads, and bucket encryption updates.
1. Use explicit rollback criteria and a pre-approved detach procedure before broad attachment.
1. Expand in small OU increments with observation windows between rollouts.

Known incident informing this approach:

1. A previous broad SCP attachment across the Modernisation Platform OU caused unintended disruption, so object-write controls must be staged conservatively and only expanded after validated pilot outcomes.

## References

- AWS S3 User Guide: Blocking and restricting server-side encryption with customer-provided keys (includes current default encryption behaviour context): https://docs.aws.amazon.com/AmazonS3/latest/userguide/blocking-unblocking-s3-c-encryption-gpb.html?icmpid=docs_amazons3_console

## Evidence from testing

Local policy and SCP-style tests validated:

1. `s3:PutObject` with `AES256` is denied when the object-level deny statement is present.
1. `s3:PutObject` with `aws:kms` succeeds as expected.
1. `s3:PutObject` without explicit header can still succeed and may resolve to default encryption behaviour.
1. Bucket encryption controls are sensitive to API/action semantics and require specific testing around `s3:PutEncryptionConfiguration`.

Test setup lessons learned:

1. Test identities need explicit allow permissions for S3 operations; deny-only policies cause misleading failures.
1. Bucket creation and bucket encryption configuration are separate operations (including under Terraform, which still performs separate underlying AWS API actions).

## Consequences

### Positive

- Consistent organisation-level control for the most reliable and test-proven case.
- Immediate reduction in explicit SSE-S3 object uploads.
- Cleaner policy model aligned to verified IAM action names and API behaviour.

### Trade-offs and risks

- Existing workloads that depend on SSE-S3 defaults may still require a staged migration path.
- Bucket-level enforcement remains more complex than object-level enforcement and may require additional iteration.
- Immediate baseline does not yet guarantee fully KMS-only behaviour in every path.

### Follow-up actions

1. Re-evaluate stronger KMS-only SCP conditions after pilot results and compatibility analysis.