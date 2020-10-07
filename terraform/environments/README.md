# Modernisation Platform - Environments

This creates and maintains organisational units, their accounts, and their relationships with the Modernisation Platform. It needs to be run at the MoJ root account level, with a user that has access to assume a role within the Modernisation Platform.

## tldr
- Run `make download_required_files` with the applicable AWS profile set before running Terraform `init`, `plan`, `apply`

## Providers
There are two types of providers in this configuration.

### Static providers
In [main.tf](main.tf), the default AWS provider is the MoJ root account. There is a secondary provider, with the alias `modernisation-platform`, that assumes the `OrganizationAccountAccessRole` in the Modernisation Platform account.

### Generated providers
As of 2020-09-29, there is an open issue regarding [dynamic providers in Terraform](https://github.com/hashicorp/terraform/issues/24476). Therefore, we need to generate a file that defines providers as "static" blocks.

`providers.tf` creates a local variable that runs `templatefile()` on [providers.tmpl](providers.tmpl), which loops through accounts created within the `environments` module and applies configuration on each one.

This is then uploaded to the `modernisation-platform-terraform-state` S3 bucket.

#### Getting around the cyclical dependency on generated providers
When Terraform runs, it compares your local state to the remote state held in S3. If you don't have the generated provider file, it'll throw an error saying that you need them, because it can't compare the state without them. To get around this, we've included a Makefile that holds a directive to download the required files from an S3 bucket without Terraform. This should be run before `terraform init, plan, apply` to ensure you've got the up to date file.

## State management
The Terraform state is stored in the `modernisation-platform-terraform-state` bucket alongside other states creates in this repository. The user that this configuration should be run as needs access.
