# Get the environments file from the main repository
data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.application_name}.json"
}

#### Custom data ####
# AWS Generated policy for role which is imported
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "email" {
  #checkov:skip=CKV_AWS_111
  #checkov:skip=CKV_AWS_356: Policy follows AWS guidance
  statement {
    actions = [
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}
