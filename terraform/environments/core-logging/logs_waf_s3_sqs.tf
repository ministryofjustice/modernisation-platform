# SQS Queue for modernisation platform waf logs bucket for XSIAM
resource "aws_sqs_queue" "mp_modernisation_platform_waf_logs_queue" {
  name                       = "mp_modernisation_platform_waf_logs_queue"
  sqs_managed_sse_enabled    = true
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
}

data "aws_iam_policy_document" "modernisation_platform_waf_logs_queue_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.mp_modernisation_platform_waf_logs_queue.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.s3-bucket-modernisation-platform-waf-logs.bucket.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "modernisation_platform_waf_logs_queue_policy" {
  queue_url = aws_sqs_queue.mp_modernisation_platform_waf_logs_queue.id
  policy    = data.aws_iam_policy_document.modernisation_platform_waf_logs_queue_policy_document.json
}

resource "aws_s3_bucket_notification" "modernisation_platform_waf_logs_bucket_notification" {
  bucket = module.s3-bucket-modernisation-platform-waf-logs.bucket.id
  queue {
    queue_arn = aws_sqs_queue.mp_modernisation_platform_waf_logs_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
