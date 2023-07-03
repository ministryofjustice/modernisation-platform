data "aws_iam_policy_document" "airflow_ses_policy" {
  statement {
    sid       = "AllowSESSendRawEmail"
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = ["arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${local.environment_configuration.ses_domain_identity}"]
    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = [local.airflow_mail_from_address]
    }
  }
}

module "airflow_ses_policy" {
  # checkov:skip=CKV_TF_1:
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5"

  name   = "${local.application_name}-${local.environment}-airflow-ses"
  policy = data.aws_iam_policy_document.airflow_ses_policy.json

  tags = local.tags
}

data "aws_iam_policy_document" "airflow_execution_policy" {
  statement {
    sid       = "AllowAirflowPublishMetrics"
    effect    = "Allow"
    actions   = ["airflow:PublishMetrics"]
    resources = ["arn:aws:airflow:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:environment/${local.airflow_name}"]
  }
  statement {
    sid       = "DenyS3ListAllMyBuckets"
    effect    = "Deny"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowS3GetListBucketObjects"
    effect = "Allow"
    actions = [
      "s3:GetBucket*",
      "s3:GetObject*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::${data.aws_s3_bucket.airflow.id}",
      "arn:aws:s3:::${data.aws_s3_bucket.airflow.id}/*"
    ]
  }
  statement {
    sid    = "AllowCloudWatchLogsCreatePutGet"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${local.airflow_name}-*"]
  }
  statement {
    sid       = "AllowCloudWatchLogGroupsDescribe"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowS3GetAccountPublicAccessBlock"
    effect    = "Allow"
    actions   = ["s3:GetAccountPublicAccessBlock"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowCloudWatchPutMetricData"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
  statement {
    sid    = "AllowSQSChangeDeleteGetReceiveSend"
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = ["arn:aws:sqs:${data.aws_region.current.name}:*:airflow-celery-*"]
  }
  statement {
    sid       = "AllowEKSDescribeCluster"
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [local.environment_configuration.eks_cluster_arn]
  }
}

module "airflow_execution_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name   = "${local.application_name}-${local.environment}-airflow-execution"
  policy = data.aws_iam_policy_document.airflow_execution_policy.json

  tags = local.tags
}
