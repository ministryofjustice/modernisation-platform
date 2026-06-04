# 25. Non Standard User Infrastructure

Date: 2023-06-20

## Status

⌛ Superseded

[Member infrastructure code was moved to the modernisation-platform-environments respository.](https://github.com/ministryofjustice/modernisation-platform/issues/5926).
There may be occasions where we store secrets within the MP repository as they need to persist in case of an environment rebuild, but otherwise all member infrastructure is provisioned through [modernisation-platform-environments](https://github.com/ministryofjustice/modernisation-platform-environments).

## Context

The Modernisation Platform is built to host as wide a range of applications as possible. In order to maintain security some actions are not allowed in the environments repository and do not have the relevant permissions, for example creating IAM users, or VPCs.

However there are times when an application may reasonably want to create these resources, for example to create a user for use with SES.

The question is how do we create these resources without compromising wider platform controls.

## Decision

Non standard infrastructure code will be held in the [Modernisation Platform environments folders](https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/environments).  This Terraform is primarily used to create RAM shares for the shared networking, but it also runs with a role which has permissions to create most resources.

## Consequences

- Non standard infrastructure code be be located in the [Modernisation Platform environments folders](https://github.com/ministryofjustice/modernisation-platform/tree/main/terraform/environments).
- Code added here will need a review from the Modernisation Platform team.
- We should implement workflows for the Terraform in these folders so that manual applies are not required as they are currently.