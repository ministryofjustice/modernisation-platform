# 11. Use VPC flow logs to gain insight into network state

Date: 2021-09-24

## Status

❌ Rejected

## Context

A core part of the Modernisation Platform is its network topology and configuration and we naturally want confidence that it exists in its desired state to meet security, compliance and best-practise requirements. We want to use the right products and tools that offer networking monitoring and testing capabilities to provide us with this confidence.

## Decision

[VPC flow flows](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) contain information about data coming into and out of attached network interfaces. As such, flow log data could be collected, aggregated, analysed and visualised in order to provide insights into the traffic flowing (or not) through VPCs. VPC flow logs are already collected in environment accounts and at the platform-level in the core-logging account, within CloudWatch log groups.

## Consequences

### General consequences

* vpc flow logs would probably need to be centralised into a central S3 bucket
* log data could then be queried (using [Athena](https://docs.aws.amazon.com/athena/latest/ug/vpc-flow-logs.html)) - the results of which could then be visualised with an appropriate tool

### Advantages

* flow logs are a native aws feature and there are lots of common scenarios around their collection and analysis
* a bespoke capability could be designed and engineered to analyse, visualise and even create aws cloudwatch alarms on flow log events. For example, [this](https://aws.amazon.com/blogs/big-data/analyzing-vpc-flow-logs-with-amazon-kinesis-firehose-amazon-athena-and-amazon-quicksight/) blog post cites one of many possibilities.
  
### Disadvantages

* taking a bespoke approach to engineering a solution that utilises flow logs may not be consistent with the wider networking monitoring strategy
* flow logs by definition only show describe existing traffic traffic flows. They would describe events where traffic flows are blocked but not where the traffic flow has stopped for other reasons, e.g. software firewall blocking.

## Reason for rejection

Given the current set of requirements, the simple ability we already have to search across log groups and the desire to have a wider story around monitoring, these arguments to develop our use of vpc flow logs at this time are not sufficiently convincing.

## Useful links
[Google doc capturing networking testing requirements, principals and related spike stories](https://docs.google.com/document/d/1WTLqsA1XUtahLnif42A1vGyMg7-284z-c4MllZj4GT0/edit#)
