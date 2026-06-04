# read-only-users

This repository holds a Terraform module that creates set IAM accounts and associated configuration, such as: account password policies, administrator groups, user accounts.

## First-sign in and changing a password
The included force_mfa IAM policy doesn't allow a user to change their password without MFA enabled. When onboarding a new superadmin,
they will need to configure MFA before logging in for the first time.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.8 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_user"></a> [iam\_user](#module\_iam\_user) | terraform-aws-modules/iam/aws//modules/iam-user | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_user_policy.user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | List of accounts to give access to with access levels | `list(any)` | n/a | yes |
| <a name="input_environment_management"></a> [environment\_management](#input\_environment\_management) | Environment management json | <pre>object({<br/>    account_ids                                 = map(string)<br/>    aws_organizations_root_account_id           = string<br/>    modernisation_platform_account_id           = string<br/>    modernisation_platform_organisation_unit_id = string<br/>  })</pre> | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | User name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_username"></a> [username](#output\_username) | n/a |
<!-- END_TF_DOCS -->