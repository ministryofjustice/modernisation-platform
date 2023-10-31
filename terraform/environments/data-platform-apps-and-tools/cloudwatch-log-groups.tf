module "openmetadata_opensearch_cloudwatch_log_group" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 4.0"

  name              = "/aws/opensearch/openmetadata"
  retention_in_days = 400

  tags = local.tags
}

data "aws_iam_policy_document" "opensearch_cloudwatch_logs" {
  statement {
    sid    = "AllowOpenSearchPublishCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch"
    ]
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    resources = ["${module.openmetadata_opensearch_cloudwatch_log_group.cloudwatch_log_group_arn}*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_cloudwatch_logs" {
  policy_name     = "opensearch-cloudwatch-logs"
  policy_document = data.aws_iam_policy_document.opensearch_cloudwatch_logs.json
}
