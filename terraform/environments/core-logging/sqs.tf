# This covers the SQS and related infrastructure that allows Cortex XSIAM service to access updates to the cloudtrail logging bucket

# SQS Queue to present the logging bucket updates
resource "aws_sqs_queue" "mp_cloudtrail_log_queue" {
  name                       = "mp_cloudtrail_log_queue"
  sqs_managed_sse_enabled    = true   # Using managed encryption
  delay_seconds              = 0      # The default is 0 but can be up to 15 minutes
  max_message_size           = 262144 # 256k which is the max size
  message_retention_seconds  = 345600 # This is 4 days. The max is 14 days
  visibility_timeout_seconds = 30     # This is only useful for queues that have multiple subscribers
}

# This policy grants queue send message to the s3 logging bucket
resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.mp_cloudtrail_log_queue.id
  policy    = data.aws_iam_policy_document.queue_policy_document.json
}

data "aws_iam_policy_document" "queue_policy_document" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [
      aws_sqs_queue.mp_cloudtrail_log_queue.arn
    ]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.s3-bucket-cloudtrail.bucket.arn]
    }
  }
}

# S3 bucket event notification for updates to the cloudtrail logging bucket
resource "aws_s3_bucket_notification" "logging_bucket_notification" {
  bucket = module.s3-bucket-cloudtrail.bucket.id
  queue {
    queue_arn = aws_sqs_queue.mp_cloudtrail_log_queue.arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}
