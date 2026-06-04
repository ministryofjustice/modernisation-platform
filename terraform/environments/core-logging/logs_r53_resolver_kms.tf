resource "aws_kms_key" "r53_resolver_logs" {
  description         = "KMS key used to encrypt R53 Resolver Logs CloudWatch log group"
  enable_key_rotation = true
  multi_region        = true
  policy              = data.aws_iam_policy_document.r53_resolver_logs_kms.json
  tags                = local.tags
}

data "aws_iam_policy_document" "r53_resolver_logs_kms" {
  #checkov:skip=CKV_AWS_109:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_111:"Policy is directly related to the resource"
  #checkov:skip=CKV_AWS_356:"Policy is directly related to the resource"
  statement {
    sid    = "Allow management access of the key to the logging account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid    = "Allow AWS Log service to use key"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com"
      ]
    }
  }
}

