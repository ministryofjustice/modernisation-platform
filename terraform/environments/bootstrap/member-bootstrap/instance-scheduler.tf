# role for allowing the instance scheduler to shut down and start up instances in accounts

module "instance-scheduler-access" {
  count                  = local.account_data.account-type == "member" && terraform.workspace != "testing-test" ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648"
  account_id             = local.environment_management.account_ids["core-shared-services-production"]
  additional_trust_roles = [format("arn:aws:iam::%s:role/InstanceSchedulerLambdaFunctionPolicy", local.environment_management.account_ids["core-shared-services-production"])]
  policy_arn             = aws_iam_policy.instance-scheduler-access[0].id
  role_name              = "InstanceSchedulerAccess"
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "instance-scheduler-access" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    #checkov:skip=CKV_AWS_356: Resources not known in advance
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeTags",
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt"
    ]
  }
  # checkov:skip=CKV_AWS_111: "Will need to potentially create grants on multiple keys"
  statement {
    actions = [
      "kms:CreateGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "instance-scheduler-access" {
  count       = local.account_data.account-type == "member" ? 1 : 0
  name        = "InstanceSchedulerAccessActions"
  description = "Restricted policy for use by the Instance Scheduler Lambda in member accounts"
  policy      = data.aws_iam_policy_document.instance-scheduler-access.json
}

module "testing_instance-scheduler-access" {
  count                  = terraform.workspace == "testing-test" ? 1 : 0
  source                 = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648"
  account_id             = local.environment_management.account_ids["core-shared-services-production"]
  additional_trust_roles = [format("arn:aws:iam::%s:role/InstanceSchedulerLambdaFunctionPolicy", local.environment_management.account_ids["core-shared-services-production"]), format("arn:aws:iam::%s:root", local.environment_management.account_ids["testing-test"])]
  policy_arn             = aws_iam_policy.instance-scheduler-access[0].id
  role_name              = "InstanceSchedulerAccess"
}
