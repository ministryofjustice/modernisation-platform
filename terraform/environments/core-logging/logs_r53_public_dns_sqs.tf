# SQS Queue for modernisation platform Route 53 Public DNS Query Logs bucket updates for XSIAM
resource "aws_sqs_queue" "r53_public_dns_logs_queue" {
  name                       = "r53_public_dns_logs_queue"
  sqs_managed_sse_enabled    = true
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
  tags = {
    Name = "r53_public_dns_logs_queue"
  }
}

resource "aws_sqs_queue_policy" "r53_public_dns_logs_queue_policy" {
  queue_url = aws_sqs_queue.r53_public_dns_logs_queue.id
  policy    = data.aws_iam_policy_document.r53_public_dns_logs_queue_policy_document.json
}

data "aws_iam_policy_document" "r53_public_dns_logs_queue_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.r53_public_dns_logs_queue.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.s3_bucket_r53_public_dns_logs.bucket.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "r53_public_dns_logs_bucket_notification" {
  bucket = module.s3_bucket_r53_public_dns_logs.bucket.id
  queue {
    queue_arn = aws_sqs_queue.r53_public_dns_logs_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
