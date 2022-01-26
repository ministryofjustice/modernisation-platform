# read-only-users

This repository holds a Terraform module that creates set IAM accounts and associated configuration, such as: account password policies, administrator groups, user accounts.

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.20.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_group_readonly_with_policies"></a> [iam\_group\_readonly\_with\_policies](#module\_iam\_group\_readonly\_with\_policies) | terraform-aws-modules/iam/aws//modules/iam-group-with-policies | ~> 4.8 |
| <a name="module_iam_user"></a> [iam\_user](#module\_iam\_user) | terraform-aws-modules/iam/aws//modules/iam-user | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy.ForceMFA](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_alias"></a> [account\_alias](#input\_account\_alias) | AWS IAM account alias for this account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Map of users and PGP-encrypted passwords, e.g. { bob: 'abcdefg123456' } |

<!--- END_TF_DOCS --->

## First-sign in and changing a password
The included force_mfa IAM policy doesn't allow a user to change their password without MFA enabled. When onboarding a new superadmin,
they will need to configure MFA before logging in for the first time.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
