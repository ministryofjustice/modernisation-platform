# 6. Use a multi-account strategy for applications

Date: 2021-01-21

## Status

✅ Accepted

## Context

In the Modernisation Platform, we want to reduce the blast radius and increase the scalability of how we create, maintain, and support applications in the context of what AWS account(s) they sit within.

## Decision

We've decided to use a multi-account strategy, split by application. We have a complete write-up as part of our [environments concept](https://user-guide.modernisation-platform.service.justice.gov.uk/concepts/environments/).

## Consequences

### General consequences

We need to ensure we can support a multi-account architecture for core concepts such as:
- networking and DNS
- centralised CI/CD
- centralised logging
- centralised security

### Advantages

It allows us to benefit from:
- granular isolation at an application level
- better cost management
- increased autonomy for teams
- reduced cloud waste

### Disadvantages

We're introducing increased complexity to reduce the blast radius of AWS accounts.
