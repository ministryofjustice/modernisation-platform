data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "root_account" {}

# Get secret by name for environment management
data "aws_secretsmanager_secret" "environment_management" {
  name = "environment_management"
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

# PagerDuty user details and rotas, kept out of the repo as they are personal data. The secret must be created and
# populated manually as JSON. Keys are free-form identifiers; they are used in terraform state addresses so should not be
# changed once in use.
# {
#   "users":          { "<key>": { "name": "...", "email": "...", "role": "user|manager" } },  users managed by terraform, must include "modernisation_platform" (team mailbox, used as fallback on-call)
#   "existing_users": { "<key>": "<email>" },                                                   users that already exist in PagerDuty
#   "rotas": {
#     "primary":   ["<key>", ...],                                                              keys from users or existing_users, in rotation order
#     "secondary": ["<key>", ...]
#   },
#   "octo_platform_operations": {
#     "members":   { "<key>": "<email>" },                                                      existing PagerDuty users
#     "primary":   ["<key>", ...],                                                              keys from members, in rotation order
#     "secondary": ["<key>", ...]
#   },
#   "status_page_additional_emails": ["<email>", ...]
# }
data "aws_secretsmanager_secret" "pagerduty_users" {
  name = "pagerduty_users"
}

data "aws_secretsmanager_secret_version" "pagerduty_users" {
  secret_id = data.aws_secretsmanager_secret.pagerduty_users.id
}

data "pagerduty_user" "existing_users" {
  for_each = toset(nonsensitive(keys(local.pagerduty_secret.existing_users)))
  email    = local.pagerduty_secret.existing_users[each.key]
}

data "aws_iam_policy_document" "pagerduty_secret" {
  #cannot reference secret in resources for statement as this causes cyclic error
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_356: Policy is attached to a resource
  statement {
    sid    = "ReadOnlyFromModernisationPlatformOU"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:GetResourcePolicy", "secretsmanager:DescribeSecret"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}

data "aws_iam_policy_document" "pagerduty_kms" {
  #cannot reference secret in resources for statement as this causes cyclic error
  #checkov:skip=CKV_AWS_108
  #checkov:skip=CKV_AWS_109: "Constraint is via only mp ou condition"
  #checkov:skip=CKV_AWS_111: "Constraint is via only mp ou condition"
  #checkov:skip=CKV_AWS_356: Policy is attached to a resource
  statement {
    sid    = "AllowManagementAccountAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id, data.aws_organizations_organization.root_account.master_account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowModernisationPlatformAccountsToDecrypt"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:Decrypt*"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
    }
  }
}

# default priority for DSO pagerduty slack integration
# If ["*"] is set as elsewhere services with alarms don't change the dashboards in PagerDuty UI
# Can be over-ridden manually later when someone's taken a look at the actual alert
data "pagerduty_priority" "p5" {
  name = "P5"
}
