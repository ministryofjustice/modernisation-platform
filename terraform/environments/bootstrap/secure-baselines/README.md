# Modernisation Platform: environments bootstrapping

This directory creates and maintains commmon resources that should be available in every account. It uses `terraform workspace` and replaces the [previous process for bootstrapping accounts](https://github.com/ministryofjustice/modernisation-platform/tree/5a8fd5c6/terraform/environments).

You need to run Terraform commands in this directory using a Ministry of Justice AWS organisational root IAM user that has permissions to `sts:AssumeRole`. It utilises the `OrganizationAccountAccessRole` created by AWS Organizations to assume a role in an account and bootstrap it with the following:

- an IAM policy that is assumable by the Modernisation Platform, so you no longer have to authenticate at the highest level when working with an environment
- [modernisation-platform-terraform-baselines](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines) to configure standardised resources

## Getting started

> NB: The `default` terraform workspace is not in use, but is undeletable.

### Find available workspaces

`terraform workspace list`

### Selecting a workspace

`terraform workspace select <workspace_name>`

### Running Terraform inside a workspace

`terraform plan`

### Example for `shared-services-dev`

```terraform
terraform workspace list
terraform workspace select shared-services-dev
terraform plan
terraform apply
```

## Running this in CI/CD

This repository includes a [script to automate this](https://github.com/ministryofjustice/modernisation-platform/tree/main/scripts/create-accounts.sh) for all new workspaces.
