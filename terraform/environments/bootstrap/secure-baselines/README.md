# Modernisation Platform: environments bootstrapping

This directory configures use of [the `secure-baselines` Terraform module](https://github.com/ministryofjustice/modernisation-platform-terraform-baselines?tab=readme-ov-file#modernisation-platform-terraform-baselines-module), which creates and maintains common resources that should be available in every account.

The `secure-baselines` module:
> _enables and configures the MoJ Security Guidance baseline for AWS accounts, alongside some extra reasonable security, identity and compliance services_

New environments can be created via the [new-environment.yml](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/workflows/new-environment.yml) workflow, which includes [a `secure-baselines` step](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/workflows/new-environment.yml#L258) that uses `terraform workspace` commands to call [a `setup-baselines.sh` bash script](https://github.com/ministryofjustice/modernisation-platform/blob/main/scripts/setup-baseline.sh).

The processes here replaces the [previous process for bootstrapping accounts](https://github.com/ministryofjustice/modernisation-platform/tree/5a8fd5c6/terraform/environments).

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

New environments can be created via the [new-environment.yml](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/workflows/new-environment.yml) workflow.
