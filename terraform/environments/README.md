# Modernisation Platform - Environments

This directory creates and maintains organisational units, their accounts, and their relationships with the Modernisation Platform. It needs to be run at the MoJ root account level, with a user that has access to assume a role in the Modernisation Platform.

## Bootstrapping accounts

The subdirectory [bootstrap](bootstrap) enables bootstrapping resources in all accounts that are part of the Modernisation Platform, such as an IAM role for cross-account access and security implementations. It utilises terraform workspaces and has a [`new-environment.yml` workflow](https://github.com/ministryofjustice/modernisation-platform/blob/main/.github/workflows/new-environment.yml) to create accounts and bootstrap them as part of our CI/CD pipeline.

## State management

The Terraform state is stored in the `modernisation-platform-terraform-state` bucket alongside other states creates in this repository. The user that this configuration should be run as needs access.

The `environment_management` secret and its GitHub Actions copies include an `account_applications` map. Its keys are account names in the form `<environment-definition-filename>-<environment-name>` and its values come from the definition's top-level `tags.application`. Only non-empty string values are included. The map is regenerated from the environment definitions during Terraform reconciliation, so removing or changing an application tag updates the exported map; existing payload fields are preserved.
