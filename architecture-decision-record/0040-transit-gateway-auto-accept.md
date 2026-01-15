# 40. Transit Gateway Auto-Accept VPC Attachment Requests

Date: 2026-01-15

## Status

✅ Accepted

## Context

We received a Security Hub alert (EC2.23) flagging that our Transit Gateway automatically accepts VPC attachment requests. The default AWS recommendation is to disable auto-accept to require manual approval of each attachment request, treating it as a security risk.

However, our architecture relies on automated workflows. Disabling auto-accept would:
- Block Terraform workflows until manual console acceptance
- Cause GitHub Actions to fail and require re-runs
- Require us to refactor scripts/pipelines to gracefully handle manual acceptance of attachments

Our Transit Gateway configuration includes multiple protective layers as mitigations to this risk:
- RAM sharing to **specific accounts only** (i.e. the `core-vpc-*` accounts, not organization-wide)
- `allow_external_principals = false` prevents external sharing
- **Default route table association/propagation disabled** - rogue attachments get no routing
- All attachments managed via Infrastructure as Code in version-controlled Terraform
- Explicit route table assignment per environment type (live_data/non_live_data)
- Network segmentation with inspection VPCs, NACLs, security groups, and VPC Flow Logs

The key insight is that even if an unauthorized attachment is created, it cannot route traffic without:
1. Route table association (requires cross-account access to core-network-services that member accounts don't have)
2. RAM sharing already granting the source account access to the Transit Gateway

## Decision

We will **keep `auto_accept_shared_attachments = "enable"`** on the MP Transit Gateway and implement compensating controls through CloudWatch monitoring and alerting.

### Implemented Compensating Controls:

1. **CloudWatch Monitoring in Core-VPC Accounts** - Monitor `CreateTransitGatewayVpcAttachment` API calls to detect manual attachment creation in the four legitimate core-vpc accounts (production, preproduction, test, development)

2. **CloudWatch Monitoring in Core-Network-Services** - Monitor `AcceptTransitGatewayVpcAttachment` API calls to catch attachments from ANY account, including unauthorized accounts that may have been granted illicit RAM sharing

3. **PagerDuty Integration** - Both monitoring layers alert via PagerDuty for immediate response to unauthorized attachment creation

4. **Security Hub Control Suppression** - Disable EC2.23 control in core-network-services account with documented rationale

### Monitoring Pattern:
Both alarms exclude the `ModernisationPlatformAccess` IAM role, which is used by GitHub Actions and local Terraform runs for legitimate automation. Any attachment creation outside this role triggers an alert.

## Consequences

### Positive:
- Maintains fully automated infrastructure deployment
- Real-time detection of anomalous attachments (faster than manual review)
- Defence in depth: monitoring catches unauthorized attachment attempts from any of our accounts

### Trade-offs:
- Local Terraform runs using `ModernisationPlatformAccess` role won't trigger alarms (accepted limitation as these are authenticated platform engineers)
- Monitoring is detective, not preventive - but preventive controls exist via RAM sharing restrictions and routing configuration

### Security Outcome:
The combination of explicit RAM sharing, disabled default routing, and real-time monitoring provides equivalent security to manual approval, while maintaining operational efficiency. An attacker would need to:
1. Compromise an account that already has RAM access, AND
2. Create an attachment (which triggers alarms), AND
3. Gain cross-account access to core-network-services to configure routing

This layered defense makes unauthorised network access extremely difficult while preserving automation.

