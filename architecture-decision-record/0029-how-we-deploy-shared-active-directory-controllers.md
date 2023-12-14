# 29. How we deploy shared Active Directory controllers

Date: 2023-12-14

## Status

✅ Accepted

## Context

As we migrate applications across, we encounter situations where multiple applications have previously made use of a common Microsoft Active Directory deployment.

To provide a consistent experience, we propose to use our `core-shared-services` account to host deployments of [AWS Managed Microsoft Active Directory](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/directory_microsoft_ad.html).

## Decision

Deploying AWS Managed Microsoft Active Directory in `core-shared-services` will be done with the `live_data` VPC holding the Domain Controllers for preproduction & production.
The `non_live_data` VPC will hold the Domain Controllers for development & test.

The Modernisation Platform team will handle things like creating a common Single Sign-On role - eg `ModernisationPlatformDomainAdministrator`, as well as the required AWS IAM role & policy.
The Modernisation Platform team will also write Terraform code to provision the AWS Managed Microsoft AD into the `core-shared-services` account.

The Modernisation Platform **will not** conduct any configuration tasks on the deployed AD.

## Consequences

- Modernisation Platform team will work with customers who need AD for multiple applications.
- There will be a clear break between development/test & preproduction/production deployments.
- Modernisation Platform will host the AD deployment, but not be responsible for the configuration or maintenance of the deployment.
