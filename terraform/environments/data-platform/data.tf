# Get the environments file from the main repository
data "http" "environments_file" {
  url = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.application_name}.json"
}

data "aws_iam_policy" "cicd_member_policy" {
  name = "cicd-member-policy"
}