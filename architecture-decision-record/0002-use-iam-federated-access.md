# 2. Use IAM Federated Access

Date: 2020-09-15

## Status

❌ Rejected

## Context

The Modernisation Platform will be used by a large group of people across the Justice Digital and Technology estate, and each person will need their access to the Modernisation Platform managed.

## Decision

Rather than managing the administrative burden of the Joiners, Movers and Leavers (JML) process ourselves, we can automate this for the team by utilising IAM Federated Access to allow access management through an identity provider that is already managed within Ministry of Justice. For example, we can use GitHub, which is included as part of the department's JML process, as an identity provider for access to our AWS account.

## Consequences

- We don't have to manage the JML process ourselves
- We have the same flexibility to contain permissions as a normal IAM account
- We will need to ensure people are onboarded and offboarded in a timely manner to reduce our risks
- People who need to use the Modernisation Platform will need a GitHub account that is part of the Ministry of Justice organisation
- We don't have to manage MFA or password rotation for any self-service accounts
- IAM user accounts through IAM Federated Access don't actually exist, so can't be suspended as mentioned in the [MOJ Security Guidance](https://ministryofjustice.github.io/security-guidance/baseline-aws-accounts/#identity-and-access-management), only removed at a GitHub level
- We align ourselves with the [cloud-platform](https://github.com/ministryofjustice/cloud-platform) and [analytics-platform](https://github.com/ministryofjustice/analytics-platform) teams
