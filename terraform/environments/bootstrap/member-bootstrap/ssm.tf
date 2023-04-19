# resources for patching via SSM

module "ssm-cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.3.0"
  account_id                  = local.environment_management.account_ids["core-shared-services-production"]
  policy_arn                  = aws_iam_policy.execution-combined-policy.arn
  role_name                   = "AWS-SSM-AutomationExecutionRole"
  additional_trust_statements = [data.aws_iam_policy_document.ssm-trust-relationship-policy.json]

}
##checks being skipped until policy has been amended##
#tfsec:ignore:aws-iam-user-policy-document tfsec:ignore:AWS109 tfsec:ignore:AWS108 tfsec:ignore:AWS111
data "aws_iam_policy_document" "SSM-Automation-Policy" {
  #checkov:skip=CKV_AWS_109: "policy exception"
  #checkov:skip=CKV_AWS_108: "policy exception"
  #checkov:skip=CKV_AWS_111: "policy exception"
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:*:function:Automation*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:CreateImage",
      "ec2:CopyImage",
      "ec2:DeregisterImage",
      "ec2:DescribeImages",
      "ec2:DeleteSnapshot",
      "ec2:StartInstances",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ssm:*"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:sns:*:*:Automation*"]
    actions   = ["sns:Publish"]
  }
}

data "aws_iam_policy_document" "execution-policy" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "resource-groups:ListGroupResources",
      "tag:GetResources",
      "ec2:DescribeInstances",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/AWS-SSM-AutomationExecutionRole"]
    actions   = ["iam:PassRole"]
  }
}

data "aws_iam_policy_document" "ssm-trust-relationship-policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/AWS-SSM-AutomationAdministrationRole"]
    }
  }

  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "execution-combined-policy-doc" {
  source_policy_documents = concat([data.aws_iam_policy_document.SSM-Automation-Policy.json, data.aws_iam_policy_document.execution-policy.json])
}

resource "aws_iam_policy" "execution-combined-policy" {
  name        = "SSM-Automation-Execution-Combined-Policy"
  path        = "/"
  description = "Combined policy for SSM Automation Execution"
  policy      = data.aws_iam_policy_document.execution-combined-policy-doc.json
}
