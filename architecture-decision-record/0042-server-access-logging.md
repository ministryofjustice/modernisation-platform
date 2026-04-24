# 42. Monitor Object Access Without S3 Server Access Logging

Date: 2026-04-24

## Status

✅ Accepted

## Context

> Related requirement: DET-19 — “Do you have access logging enabled for storage buckets containing critical security logs to identify and troubleshoot unauthorized access attempts?”

Investigated [here](https://github.com/ministryofjustice/modernisation-platform-security/issues/94).

Amazon S3 Server Access Logging exists within the platform and is currently enabled for one bucket in the core-logging account:

- The CloudTrail S3 bucket (`modernisation-platform-logs-cloudtrail`) delivers its server access logs to a dedicated logging bucket (`modernisation-platform-logs-cloudtrail-logging`).

A request has been made to enable S3 Server Access Logging more broadly across other S3 buckets (for example: AWS Config logs, WAF logs, Route 53 resolver/DNS logs, VPC flow logs).

## Decision

We will not enable S3 Server Access Logging on any additional buckets.


Instead, we will meet the requirement intent using:

- CloudTrail S3 Data Events (object-level logging) for critical security log buckets to capture access attempts and outcomes (for example: `ListBucket`, `GetObject`, `PutObject`, `DeleteObject`, `AccessDenied`). This is already enabled on the platform.
- Continuing to keep S3 Server Access Logging enabled for the CloudTrail bucket where it is already configured.

### Rationale

CloudTrail S3 Data Events provide an identity-rich audit trail that is directly aligned to “identify and troubleshoot unauthorized access attempts”, including:

- Who performed the action (principal/role context)
- What action was attempted (`ListBucket`, `GetObject`, `DeleteObject`, etc.)
- Which bucket/object was targeted (bucket name and object key)
- Whether it succeeded or failed (`AccessDenied`, etc.)
- Source IP, user agent, and other request context

This is generally more operationally effective for security monitoring than S3 Server Access Logging files, which are:

- Delivered eventually (not real-time)
- Often high volume and noisy on busy log buckets
- Typically require additional ingestion/querying pipelines (Athena/SIEM) to be operationally useful  

Per AWS documentation, S3 Server Access Logging mainly adds HTTP-level and bucket-operation fields that are not required to satisfy the DET-19 intent in our context. These include object size and bytes transferred, request timing metrics (total time and turn-around time), detailed HTTP status codes and 
HTTP headers such as referrer and user agent.

While S3 access logs capture **authentication failures (e.g. invalid credentials)**, these occur before identity can be established and are typically harder to investigate (for example, you may not be able to attribute them to a principal).

CloudTrail does not log these authentication failures, but **does capture authorization failures (`AccessDenied`) and anonymous requests**, which are the relevant signals for detecting unauthorized access.

Reference: https://docs.aws.amazon.com/AmazonS3/latest/userguide/logging-with-S3.html

## Consequences

### Positive

- Meets the DET-19 intent using a single, consistent audit source (CloudTrail) that is identity-centric and alert-friendly
- Avoids generating and retaining large volumes of additional S3 access log objects
- Reduces operational burden (no new access log ingestion/parsing pipelines)


### Trade-offs

- We do not gain certain HTTP-level fields provided by S3 Server Access Logging (for example: bytes sent / detailed request timing)
- We do not gain visibility of authentication failures

These are considered acceptable given the limited security value in this context.

### Conclusion

CloudTrail S3 Data Events provide sufficient, identity-rich visibility to meet the DET-19 control objective. Enabling Amazon S3 Server Access Logging would introduce additional cost and operational complexity with limited incremental security benefit, and is therefore not required at this time.

