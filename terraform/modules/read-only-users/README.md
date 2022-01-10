# read-only-users

This repository holds a Terraform module that creates set IAM accounts and associated configuration, such as: account password policies, administrator groups, user accounts.

<!--- BEGIN_TF_DOCS --->
<!--- END_TF_DOCS --->

## First-sign in and changing a password
The included force_mfa IAM policy doesn't allow a user to change their password without MFA enabled. When onboarding a new superadmin,
they will need to configure MFA before logging in for the first time.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
