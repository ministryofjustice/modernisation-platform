resource "aws_iam_role" "cortex_xsiam_role" {
  description        = "Role utilised by Palo Alto Cortex XSIAM"
  name_prefix        = "cortex_xsiam"
  assume_role_policy = data.aws_iam_policy_document.cortex_trust_policy.json
  tags               = local.tags
}

resource "aws_iam_policy" "cortex_xsiam_policy" {
  name        = "cortex-user-policy"
  description = "Allows the access to the created SQS queue"
  policy      = data.aws_iam_policy_document.cortex_user_policy.json
}

resource "aws_iam_role_policy_attachment" "cortex_xsiam_role" {
  policy_arn = aws_iam_policy.cortex_xsiam_policy.arn

  role = aws_iam_role.cortex_xsiam_role.name
}

data "aws_iam_policy_document" "cortex_user_policy" {
  statement {
    sid    = "SQSQueueReceiveMessages"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues"
    ]
    resources = flatten([
      aws_sqs_queue.mp_cloudtrail_log_queue.arn,
      aws_sqs_queue.mp_modernisation_platform_waf_logs_queue.arn,
      aws_sqs_queue.mp_config_logs_queue.arn,
      aws_sqs_queue.r53_public_dns_logs_queue.arn,
      [for key in aws_sqs_queue.logging : key.arn]
    ])
  }
  statement {
    sid     = "S3GetLogs"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = concat(
      [
        module.s3-bucket-cloudtrail.bucket.arn,
        "${module.s3-bucket-cloudtrail.bucket.arn}/*",
        module.s3-bucket-modernisation-platform-waf-logs.bucket.arn,
        "${module.s3-bucket-modernisation-platform-waf-logs.bucket.arn}/*",
        module.s3_bucket_config_logs.bucket.arn,
        "${module.s3_bucket_config_logs.bucket.arn}/*",
        module.s3_bucket_r53_public_dns_logs.bucket.arn,
        "${module.s3_bucket_r53_public_dns_logs.bucket.arn}/*"
      ],
      [for key in aws_s3_bucket.logging : "${key.arn}/*"]
    )
  }
}

resource "random_uuid" "cortex" {}
data "aws_iam_policy_document" "cortex_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${aws_ssm_parameter.cortex_account_id.insecure_value}:root"]
      # Palo Alto Cortex AWS Account ID
      # Taken from https://docs-cortex.paloaltonetworks.com/r/Cortex-XDR/Cortex-XDR-Pro-Administrator-Guide/Create-an-Assumed-Role
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [sensitive(random_uuid.cortex.result)]
    }
  }
}

