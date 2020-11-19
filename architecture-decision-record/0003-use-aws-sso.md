# 3. Use AWS SSO

Date: 2020-10-21

## Status

✅ Accepted

## Context

The Modernisation Platform will be used by a large group of people across the Justice Digital and Technology estate, and each person will need their access to the Modernisation Platform managed.

## Decision

Rather than managing the administrative burden of the Joiners, Movers and Leavers (JML) process ourselves, we can use AWS SSO with SCIM automated provisioning to allow access management through an Identity Provider that is already managed within Ministry of Justice, such as G-Suite. AWS SSO provides some advantages, and some disadvantages, over [IAM Federated Access](0002-use-iam-federated-access.md), as listed below.

We can, if we wish, still utilise a different service (e.g. GitHub) as a IdP through Auth0, whilst SCIM provisioning with a different IdP (e.g. G-Suite).

We decided to use AWS SSO in favour of [IAM Federated Access](0002-use-iam-federated-access.md) to allow us to centrally manage identities across the Ministry of Justice at the organisational level rather than at a team level.

A further benefit of this is that AWS SSO can be used across all AWS accounts, not just ones provisioned within the Modernisation Platform, as long as the AWS account is part of the AWS organisation.

## Consequences

### General consequences
- We don't have to manage the JML process ourselves
- We will need to ensure people are onboarded and offboarded in a timely manner to reduce our risks
- We don't have to manage MFA or password rotation for any self-service accounts
- We have the same flexibility to contain permissions as a normal IAM account

### Advantages over IAM Federated Access
- We can allow fine-grained access to multiple AWS accounts at a central level without having to configure IAM Federated Access for each one
- We can utilise AWS SSO to enable SSO with custom SAML apps that we host
- AWS SSO automatically shows you your relationship with AWS accounts and custom SAML applications, so you don't need to remember their account ID
- It simplifies access configuration for newly provisioned accounts
- Permission sets are reusable across accounts, so you don't need to configure them in each
- You can group users by abritrary methods to provide access (e.g. LAA Ops team, with a Permission Set to access all the LAA accounts)

### Disadvantages over IAM Federated Access
- AWS SSO will need to be managed at the MoJ root account level (can also be advantageous)
- We won't be aligning ourselves with the [cloud-platform](https://github.com/ministryofjustice/cloud-platform) and [analytics-platform](https://github.com/ministryofjustice/analytics-platform) teams at present (as at October 2020)
- AWS SSO doesn't have a Terraform provider but they are being actively worked on (as at October 2020)
- You have to provision users before they can login, but you can use SCIM automatic provisioning to do this
