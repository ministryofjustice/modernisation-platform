# Modernisation Platform - Environments

This directory creates and maintains organisational units, their accounts, and their relationships with the Modernisation Platform. It needs to be run at the MoJ root account level, with a user that has access to assume a role in the Modernisation Platform.

## Providers
There are two types of providers in this configuration.

### Static providers
In [main.tf](main.tf), the default AWS provider is the MoJ root account. There is a secondary provider, with the alias `modernisation-platform`, that assumes the `OrganizationAccountAccessRole` in the Modernisation Platform account from the default provider.

### Generated providers
As of 2020-09-29, there is an [open issue regarding dynamic providers](https://github.com/hashicorp/terraform/issues/24476) in Terraform. Therefore, we need to generate a file that defines providers as "static" blocks.

`providers.tf` creates local files from [../templates/providers.tmpl](../templates/providers.tmpl) for each account that is created within the `environments` module. These are output as files named `providers-${provider_key}.tf`. The generated file for each account also configures [baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines), such as SecurityHub, and [creates an IAM role that is assumable by the Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access).

## State management
The Terraform state is stored in the `modernisation-platform-terraform-state` bucket alongside other states creates in this repository. The user that this configuration should be run as needs access.
