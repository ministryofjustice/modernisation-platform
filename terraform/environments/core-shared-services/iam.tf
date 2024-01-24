data "aws_iam_role" "vpc-flow-log" {
  name = "AWSVPCFlowLog"
}

# Create IAM role and instance profile for image builder
# Instance profile gets associated to the image builder Infrastructure Configuration resource
data "aws_iam_policy" "image_builder_managed_policies" {
  for_each = toset([
    "EC2InstanceProfileForImageBuilder",
    "AmazonSSMManagedInstanceCore"
  ])
  name = each.key
}

data "aws_iam_policy_document" "image_builder_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "image_builder" {
  name                = "image-builder"
  assume_role_policy  = data.aws_iam_policy_document.image_builder_assume_policy.json
  managed_policy_arns = [for k in data.aws_iam_policy.image_builder_managed_policies : k.arn]
}

resource "aws_iam_instance_profile" "image_builder" {
  name = "image-builder"
  role = aws_iam_role.image_builder.name
}

# Role to allow member developer SSO user to perform required shared services tasks
resource "aws_iam_role" "member_shared_services" {
  name = "member-shared-services"
  assume_role_policy = jsonencode( # checkov:skip=CKV_AWS_60: "the policy is secured with the condition"
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "ForAnyValue:StringLike" : {
              "aws:PrincipalOrgPaths" : ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
            }
          }
        }
      ]
  })

  tags = merge(
    local.tags,
    {
      Name = "member-shared-services"
    },
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "member_shared_services" {
  # checkov:skip=CKV_AWS_355: Resources are not known
  # checkov:skip=CKV_AWS_290: Resources are not known
  name = "MemberSharedServices"
  role = aws_iam_role.member_shared_services.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "imagebuilder:StartImagePipelineExecution",
          "support:Describe*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "member_shared_services_readonly" {
  role       = aws_iam_role.member_shared_services.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

## BEGIN: IAM for Instance Scheduler Lambda Function

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "instance-scheduler-lambda-function-policy" {
  statement {
    sid    = "AllowLambdaToCreateLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      format("arn:aws:logs:eu-west-2:%s:*", data.aws_caller_identity.current.account_id)
    ]
  }
  statement {
    sid    = "AllowLambdaToWriteLogsToGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      format("arn:aws:logs:eu-west-2:%s:*", data.aws_caller_identity.current.account_id)
    ]
  }
  statement {
    sid    = "EC2StopAndStart"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/InstanceSchedulerAccess"
    ]
  }
  statement {
    sid    = "AllowAccessParameter"
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      format("arn:aws:ssm:*:%s:parameter/environment_management_arn", data.aws_caller_identity.current.account_id)
    ]
  }
  statement {
    sid    = "AllowAccessEnvironmentManagementSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      format("arn:aws:secretsmanager:eu-west-2:%s:secret:environment_management*", local.environment_management.modernisation_platform_account_id)
    ]
  }
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_109: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }
  statement {
    sid    = "AllowLambdaToPublishToSNSTopics"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.on_success.arn,
      aws_sns_topic.on_failure.arn
    ]
  }
}

## END: IAM for Instance Scheduler Lambda Function

# OIDC Confiuration for core-shared-services
module "github-oidc" {
  source                 = "github.com/ministryofjustice/modernisation-platform-github-oidc-provider?ref=82f546bd5f002674138a2ccdade7d7618c6758b3" # v3.0.0
  additional_permissions = data.aws_iam_policy_document.oidc_assume_role_core.json
  github_repositories    = ["ministryofjustice/modernisation-platform-instance-scheduler:*"]
  tags_common            = { "Name" = format("%s-oidc", terraform.workspace) }
  tags_prefix            = ""
}


data "aws_iam_policy_document" "oidc_assume_role_core" {
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: Resource not known
  statement {
    sid       = "AllowOIDCToDecryptKMS"
    effect    = "Allow"
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards
    actions   = ["kms:Decrypt"]
  }

  # checkov:skip=CKV_AWS_111: "There's no naming convention for lambda functions at the moment"
  statement {
    sid       = "AllowUpdateLambdaCode"
    effect    = "Allow"
    resources = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:function:*"]
    actions   = ["lambda:UpdateFunctionCode"]
  }

  # GH action: used with GO tests
  statement {
    sid       = "AllowGoToRunLambda"
    effect    = "Allow"
    resources = [module.instance_scheduler.lambda_function_arn]
    actions   = ["sts:AssumeRole"]
  }
}

##### Cross Account Roles Admin #####
#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "ssm-automation-execution-policy" {
  # checkov:skip=CKV_AWS_356
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/SSM-Automationexecution-role"]
    actions   = ["sts:AssumeRole"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["organizations:ListAccountsForParent"]
  }
}
data "aws_iam_policy_document" "ssm-automation-execution-policy-trust-relationship" {
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

resource "aws_iam_policy" "ssm-cross-account-admin-policy" {

  name        = "SSM-Automation-Execution-Policy"
  path        = "/"
  description = "Policy for SSM Automation Execution on the admin account"
  policy      = data.aws_iam_policy_document.ssm-automation-execution-policy.json
}


module "ssm-cross-account-access-admin" {
  source                      = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=6819b090bce6d3068d55c7c7b9b3fd18c9dca648" #v3.0.0
  account_id                  = local.environment_management.account_ids["core-shared-services-production"]
  policy_arn                  = aws_iam_policy.ssm-cross-account-admin-policy.arn
  role_name                   = "AWS-SSM-AutomationAdministrationRole"
  additional_trust_statements = [data.aws_iam_policy_document.ssm-automation-execution-policy-trust-relationship.json]

}

## BEGIN: IAM for EventBridge Scheduler to trigger Lambda Function

resource "aws_iam_policy" "lambda_invoke_policy" {
  name = "Lambda-Invoke-Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"]
        Effect   = "Allow"
        Resource = "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:root"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_invoke_role_policy" {
  name = "LambdaInvoke"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:function:*"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.lambda_invoke_role_policy.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}

## END: IAM for EventBridge Scheduler to trigger Lambda Function
