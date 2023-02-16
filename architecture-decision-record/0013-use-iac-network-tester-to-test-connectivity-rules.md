# 13. Use IaC Network tester to test connectivity rules

Date: 2021-09-24

## Status

❌ Rejected

## Context

A core part of the Modernisation Platform is its network topology and configuration and we naturally want confidence that it exists in its desired state to meet security, compliance and best-practise requirements. We want to use the right products and tools that offer networking monitoring and testing capabilities to provide us with this confidence.

## Decision

[IaC network tester](https://aws.amazon.com/blogs/networking-and-content-delivery/integrating-network-connectivity-testing-with-infrastructure-deployment/) is a programmatic wrapper around the [AWS Reachability Analyzer](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html). It supports automated executions of the Reachability Analyzer, with feedback indicating if the network connectivity test was successful or not. Such a tool could allow us to automatically test network connectivity and take actions on the results.

## Consequences

### General consequences

* effort would be required to transform terraform outputs into a state acceptable as inputs into the IaC network tester (by default it seems only to tightly integrate with CloudFormation stacks)
* it can only test connectivity between deployed resources such as ec2 instances, network interfaces, network gateways and internet gateways

### Advantages

* it potentially allows us to codify expected connectivity and alert on deviations

### Disadvantages

* the source and destination resources must be in the same VPC or in VPCs that are connected through a VPC peering connection. In the case of a shared VPC (as is the case within the Modernisation Platform), the resources must be owned by the same AWS account. This provides a limitation to what we can test, i.e. only connectivity within a VPC, i.e. within a business unit's VPC within a particular environment. We would be unable to test across VPC, e.g. across business units or across environments
* application of the IaC Network Tester tool would depend on transforming outputs from our IaC tool of choice, Terraform, into a format capable of being parsed.

## Reason for rejection

Given the disadvantages around the tool itself, specifically the limitations around cross-VPC testing and the fact that use-cases for testing __within__ a VPC don't currently exist at this point in time, the arguments for using it are not sufficiently convincing.

## Useful links
[Google doc capturing networking testing requirements, principals and related spike stories](https://docs.google.com/document/d/1WTLqsA1XUtahLnif42A1vGyMg7-284z-c4MllZj4GT0/edit#)
