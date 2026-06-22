# 45. Centralise VPC endpoints in core-network-services with Route53 Profiles

Date: 2026-06-19

## Status

🤔 Proposed

## Context

VPC interface endpoints are currently deployed per-VPC in a number of places. This gives private connectivity to AWS services, but it duplicates hourly endpoint cost and creates repeated DNS/routing configuration overhead.

Container Platform (CP) is scaling to additional VPCs, making endpoint-per-VPC patterns more expensive and harder to manage. AWS guidance for multi-VPC environments recommends centralised private endpoint access patterns.

The implementation also needs to align with Route53 Profiles as the DNS distribution mechanism.

## Decision

We will implement a centralised endpoint pattern in `core-network-services`:

- Create a dedicated endpoints VPC attached to the Transit Gateway.
- Create a curated set of shared interface endpoints in that VPC.
- Share endpoint resources to CP and Cloud Platform consumer accounts using AWS RAM.
- Create Route53 private hosted zones for endpoint service names and alias them to central endpoints.
- Use a Route53 Profile to group those private zones and share that profile to consumer accounts using AWS RAM.

## Consequences

- Endpoint costs become concentrated and are expected to reduce overall spend as consuming VPC count grows.
- DNS and endpoint governance moves into `core-network-services`, consistent with existing networking ownership.
- Consumer teams need a small onboarding step: accept RAM shares and associate the shared Route53 Profile with their consuming VPCs.
- Migration from existing endpoint-per-VPC deployments is a separate phased activity and will be tracked in follow-on tickets.
