# 29. How we deploy shared Active Directory controllers

Date: 2023-12-14

## Status

✅ Accepted

## Context

As we migrate applications across, we encounter situations where multiple applications have previously made use of a common Microsoft Active Directory deployment.

Discussion with customers has lead us to believe that we can best accommodate them by deploying EC2 instances to host Microsoft Domain Controller services in our `core-shared-services` account.

## Decision

Deploying Microsoft Active Directory in `core-shared-services` will be done with the `live_data` VPC holding the Domain Controllers for preproduction & production.
The `non_live_data` VPC will hold the Domain Controllers for development & test.

The Modernisation Platform team will maintain responsibility for managing any required Single Sign-On role, as well as the required AWS IAM role & policy.
The Modernisation Platform team will also write Terraform code to provision the EC2 instances that will run Microsoft Active Directory into the `core-shared-services` account.

The Modernisation Platform **will not** conduct any configuration tasks on the deployed AD.

## Consequences

- Modernisation Platform team will work with customers who need AD for multiple applications.
- There will be a clear break between development/test & preproduction/production deployments.
- Modernisation Platform will host the AD deployment, but not be responsible for the configuration or maintenance of the deployment.
