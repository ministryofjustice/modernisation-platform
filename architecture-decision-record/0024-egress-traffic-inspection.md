# 24. Egress Traffic Inspection

Date: 2023-03-30

## Status

✅ Accepted

## Context

The Modernisation Platform needs to balance the inspection of egress traffic with the preservation of separation between `live` and `non_live`. This requirement has come as a prerequisite to allowing HTTP traffic to leave the Modernisation Platform towards the internet.

## Decision

We will maintain two separate egress VPCs for `live` and `non_live` environments.

We will use AWS Network Firewall to apply FQDN-based inspection to traffic destined for HTTP endpoints.

We will use [in-line inspection](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall-with-vpc-routing-enhancements/#:~:text=2)%20AWS%C2%A0Network%C2%A0Firewall%20deployed%20to%20protect%20traffic%20between%20a%20workload%20private%20subnet%20and%20NAT%20gateway) in our egress VPCs.

## Consequences

- [x] Update diagrams showing flow of traffic out of Modernisation Platform to internet
- [ ] Raise tickets to cover scope of work.
