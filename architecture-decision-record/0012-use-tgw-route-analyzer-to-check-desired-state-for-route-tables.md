# 12. Use Transit Gateway Route Analyzer to check desired state for route tables

Date: 2021-09-24

## Status

❌ Rejected

## Context

A core part of the Modernisation Platform is its network topology and configuration and we naturally want confidence that it exists in its desired state to meet security, compliance and best-practise requirements. We want to use the right products and tools that offer networking monitoring and testing capabilities to provide us with this confidence..

## Decision

[Transit Gateway Route Analyzer](https://docs.aws.amazon.com/vpc/latest/tgw/route-analyzer.html) is an AWS tool allowing the analysis of routes in Transit Gateway Route tables. It analyzes the routing path between a specified source and destination, and returns information about the connectivity between components. It is useful in validating and troubleshooting configuration. As such, it could be used to assess the desired state for transit gateway route table configuration, providing feedback on issues.

## Consequences

### General consequences

* route analyzer is obviously only focused on Transit Gateway route tables and traffic flows through Transit Gateway attachments.

### Advantages

* offers an easy way of testing Transit Gateway route table configuration and communication between attached VPCs
  
### Disadvantages

* the tool is accessed through the AWS console UI only, there is no programmatic interface. This hinders greatly any repeatable automation
* the tool doesn’t offer a convenient method for repeated testing, being designed for diagnostics/troubleshooting rather than regular testing

## Reason for rejection

Given the disadvantages around the tool itself, it doesn't fit our requirements as a method to repeatably and automatically validate transit gateway route table configuration.

## Useful links
[Google doc capturing networking testing requirements, principals and related spike stories](https://docs.google.com/document/d/1WTLqsA1XUtahLnif42A1vGyMg7-284z-c4MllZj4GT0/edit#)
