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

data "aws_iam_policy_document" "instance-scheduler-lambda-function-assume-role" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

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
      "arn:aws:iam::*:role/MemberInfrastructureAccess"
    ]
  }
}

resource "aws_iam_role" "instance-scheduler-lambda-function" {
  assume_role_policy = data.aws_iam_policy_document.instance-scheduler-lambda-function-assume-role.json
  name               = "InstanceSchedulerLambdaFunctionPolicy"
  tags               = local.tags
}

resource "aws_iam_policy" "instance-scheduler-lambda-function" {
  policy = data.aws_iam_policy_document.instance-scheduler-lambda-function-policy.json
}

resource "aws_iam_role_policy_attachment" "instance-scheduler-lambda-function" {
  policy_arn = aws_iam_policy.instance-scheduler-lambda-function.arn
  role       = aws_iam_role.instance-scheduler-lambda-function.name
}

## END: IAM for Instance Scheduler Lambda Function
