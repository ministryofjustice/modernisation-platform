# Security Forensics Query Guide (PoC)

This document describes how to use the opt-in Athena named queries for investigating CloudTrail events in the Modernisation Platform core-logging environment.

## Overview

The existing `mod-platform` Athena workgroup and `mod_cloudtrail_logs.cloudtrail_logs` table provide partitioned CloudTrail data. This PoC adds pre-defined named queries for common forensic scenarios:

- **IAM Changes**: Investigate IAM policy, role, user, and group modifications
- **Failed Console Logins**: Track unsuccessful AWS console authentication attempts

## Prerequisites

- Read access to the `modernisation-platform-logs-cloudtrail` S3 bucket
- KMS decrypt permissions for the CloudTrail logging key
- Athena query execution permissions in the `mod-platform` workgroup
- Access to the Athena console or AWS CLI in the core-logging account

## Using Named Queries

### 1. Locate the Query

In the Athena console:
- Navigate to the **Saved queries** tab
- Find queries prefixed with `forensics-`

### 2. Replace Partition Placeholders

Each query contains **explicit partition predicates** that must be customized:

```sql
WHERE account = 'REPLACE_WITH_ACCOUNT_ID'
  AND region = 'REPLACE_WITH_REGION'
  AND timestamp BETWEEN 'YYYY/MM/DD' AND 'YYYY/MM/DD'
```

**Required replacements:**
- `REPLACE_WITH_ACCOUNT_ID`: Target AWS account ID (e.g., `123456789012`)
- `REPLACE_WITH_REGION`: AWS region (`eu-west-1` or `eu-west-2`)
- `YYYY/MM/DD`: Date range matching partition format (e.g., `2024/10/01` to `2024/10/14`)

**Important:** Partition predicates are mandatory and must match the actual partition structure:
- `account`: string (12-digit account ID)
- `region`: string (AWS region code)
- `timestamp`: string (date in `yyyy/MM/dd` format)

### 3. Review Query Plan (Recommended)

Before execution, estimate data scanned:

```sql
EXPLAIN <your_query>
```

Check the Athena console **Data scanned** estimate after a test run with a narrow date range.

### 4. Execute the Query

Run the query in the `mod-platform` workgroup. Results are written to:

```
s3://athena-cloudtrail-query-<account-id>-eu-west-2/
```

Results expire after 7 days per the bucket lifecycle policy.

## Query Descriptions

### forensics-iam-changes

Investigates IAM modifications including:
- Policy attachments/detachments
- Role creation/deletion
- User and group changes
- Permission boundary updates

**Filters:** IAM event names (e.g., `PutRolePolicy`, `AttachUserPolicy`, `CreateAccessKey`)

**Output:** Event time, user identity, event name, source IP, error code, affected resources

### forensics-failed-console-logins

Tracks failed AWS console sign-in attempts.

**Filters:** `ConsoleLogin` events with `errorCode IS NOT NULL`

**Output:** Event time, user identity, source IP, user agent, error code, error message

## Limitations (PoC Scope)

- **CloudTrail only**: Other service logs (S3 access, ALB, RDS, etc.) are not covered by these queries
- **No automated execution**: Queries must be run manually by operators
- **Partition projection**: The existing table uses partition projection; no Glue crawler or `MSCK REPAIR` is needed
- **Unverified deployment**: This PoC has not been tested with real data or deployed to production environments
- **Cost estimation**: Scanned byte comparisons require separate approval and real-world testing

## Enabling the Feature

Named queries are opt-in via Terraform variable:

```hcl
enable_forensics_queries = true  # default: false
```

With the feature disabled, no named queries are created.

## Security Considerations

- All queries include `LIMIT` clauses to prevent excessive result sets
- Partition predicates reduce data scanned and query cost
- No IAM permissions are modified by this PoC
- Existing encryption (KMS) and bucket policies remain unchanged

## Support

For questions or issues, contact the Modernisation Platform team:

**Email:** modernisation-platform@digital.justice.gov.uk

---

**Note:** This is a proof-of-concept implementation for SIP #123. Full production deployment and testing in sprinkler-development or other environments require separate approval.
