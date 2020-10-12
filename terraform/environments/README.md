# Modernisation Platform - Environments

This directory creates and maintains organisational units, their accounts, and their relationships with the Modernisation Platform. It needs to be run at the MoJ root account level, with a user that has access to assume a role in the Modernisation Platform.

## Providers
There are two types of providers in this configuration.

### Static providers
In [main.tf](main.tf), the default AWS provider is the MoJ root account. There is a secondary provider, with the alias `modernisation-platform`, that assumes the `OrganizationAccountAccessRole` in the Modernisation Platform account.

### Generated providers
As of 2020-09-29, there is an [open issue regarding dynamic providers](https://github.com/hashicorp/terraform/issues/24476) in Terraform. Therefore, we need to generate a file that defines providers as "static" blocks.

`providers.tf` creates a local variable that runs `templatefile()` on [providers.tmpl](providers.tmpl), which loops through accounts created within the `environments` module and creates an `aws_iam_role` in each account to allow the Modernisation Platform access.

This is then uploaded to the `modernisation-platform-terraform-state` S3 bucket and redownloaded if it changes remotely, creating a local file that is a replica of the S3 object.

## State management
The Terraform state is stored in the `modernisation-platform-terraform-state` bucket alongside other states creates in this repository. The user that this configuration should be run as needs access.
