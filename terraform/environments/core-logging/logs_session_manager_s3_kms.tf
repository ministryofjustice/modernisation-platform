resource "aws_kms_key" "session_manager_logs" {
  description             = "KMS key for Session Manager transcript logs"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_session_manager_logs.json
  tags                    = local.tags
}

resource "aws_kms_alias" "session_manager_logs" {
  name          = "alias/session-manager-logs-kms"
  target_key_id = aws_kms_key.session_manager_logs.id
}

data "aws_iam_policy_document" "kms_session_manager_logs" {
  # checkov:skip=CKV_AWS_109: "Policy is restricted to internal account, services and roles"
  # checkov:skip=CKV_AWS_111: "Key policy requires wildcard resource for this KMS key"
  # checkov:skip=CKV_AWS_356: "Key policy requires wildcard resource for this KMS key"
  statement {
    sid       = "AllowKeyAdmin"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowFirehoseUse"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose_to_s3_session_manager.arn]
    }
  }

  statement {
    sid    = "AllowCortexXsiamDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.cortex_xsiam_role.arn]
    }
  }
}
