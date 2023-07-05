# 26. Use Network Services account for DNS resources

Date: 2023-07-05

## Status

✅ Accepted

## Context

The Modernisation Platform uses multiple AWS accounts in line with the recommendations of the [AWS Well-Architected Framework](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html).

One of the AWS accounts we maintain is our `core-network-services` account, which contains our networking elements such as Network Firewalls, our Transit Gateway, and our Route53 resources.

## Decision

When customers request DNS zones, we will create them with our [core-network-services environment terraform](https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/environments/core-network-services).

## Consequences

- We will follow a consistent approach to creating DNS resources.
- Code added here will need a review from the Modernisation Platform team.
- We will create Terraform code to minimise the burden on application teams that want to make use of private hosted zones.
