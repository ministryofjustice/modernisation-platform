locals {
  platform_environment_files = fileset("../../../environments", "*.json")

  platform_environments = {
    for file in local.platform_environment_files :
    trimsuffix(file, ".json") => jsondecode(
      file("../../../environments/${file}")
    )
  }

  accounts = flatten([
    for app_name, config in local.platform_environments : [
      for env in config.environments : {
        business_unit = config.tags["business-unit"]
        account_name  = "${app_name}-${env.name}"
      }
    ]
  ])

  platform_business_units = distinct([
    for a in local.accounts : a.business_unit
  ])

  grouped_accounts = {
    for bu in local.platform_business_units :
    bu => [
      for a in local.accounts :
      a.account_name
      if a.business_unit == bu
    ]
  }
}

#checkov:skip=CKV_AWS_60:Cross-account trust is intentional. Access is restricted to approved business unit AWS accounts.
resource "aws_iam_role" "shared_services_secrets_access" {
  for_each = local.grouped_accounts
  name     = "${lower(each.key)}-shared-configuration-access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = [
          for account_name in each.value :
          "arn:aws:iam::${local.environment_management.account_ids[account_name]}:root"
        ]
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "shared_secrets_access" {
  for_each   = local.grouped_accounts
  role       = aws_iam_role.shared_services_secrets_access[each.key].name
  policy_arn = aws_iam_policy.shared_secrets_access[each.key].arn
}

#checkov:skip=CKV_AWS_355:AWS Secrets Manager ListSecrets and SSM DescribeParameters require wildcard resource permissions
resource "aws_iam_policy" "shared_secrets_access" {

  for_each = local.grouped_accounts
  name     = "${lower(each.key)}-shared-configuration-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:RestoreSecret",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-west-2:${local.environment_management.account_ids[terraform.workspace]}:secret:${lower(each.key)}/*"
        ]
      },
      {
        Sid    = "ListSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:DeleteParameter",
          "ssm:DeleteParameters",
          "ssm:DescribeParameters",
          "ssm:AddTagsToResource",
          "ssm:RemoveTagsFromResource",
          "ssm:ListTagsForResource"
        ]
        Resource = [
          "arn:aws:ssm:eu-west-2:${local.environment_management.account_ids[terraform.workspace]}:parameter/${lower(each.key)}/*"
        ]
      },
      {
        Sid    = "SSMParameterList"
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
}