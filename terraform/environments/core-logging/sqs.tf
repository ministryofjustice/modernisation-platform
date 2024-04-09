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
      values   = [module.s3-bucket-cloudtrail-logging.bucket.arn]
    }
  }
}

# S3 bucket event notification for updates to the cloudtrail logging bucket
resource "aws_s3_bucket_notification" "logging_bucket_notification" {
  bucket = module.s3-bucket-cloudtrail-logging.bucket.id
  queue {
    queue_arn = aws_sqs_queue.mp_cloudtrail_log_queue.arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}

##### IAM User Account & Resources to access the sqs queue

# Create an IAM policy document to allow access to the SQS Queue
data "aws_iam_policy_document" "sqs_queue_read_document" {
  statement {
    sid    = "SQSQueueReceiveMessages"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues"
    ]
    resources = [aws_sqs_queue.mp_cloudtrail_log_queue.arn]
  }
  statement {
    sid       = "SQSReadLoggingS3"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [module.s3-bucket-cloudtrail.bucket.arn, "${module.s3-bucket-cloudtrail.bucket.arn}/*"]
  }
}

# IAM policy to read the SQS queue
resource "aws_iam_policy" "sqs_queue_read_policy" {
  name        = "sqs-queue-read-policy"
  description = "Allows the access to the created SQS queue"
  policy      = data.aws_iam_policy_document.sqs_queue_read_document.json
}

# Creates an IAM user that will access the sqs queue
resource "aws_iam_user" "cortex_xsiam_user" {
  #checkov:skip=CKV_AWS_273: This has been agreed by the TA that for this purpose an IAM user account can be used.
  name = "cortex_xsiam_user"
}

resource "aws_iam_user_policy_attachment" "sqs_queue_read_policy_attachment" {
  #checkov:skip=CKV_AWS_40: User account only has a single purpose so no role or group is needed
  user       = "cortex_xsiam_user"
  policy_arn = aws_iam_policy.sqs_queue_read_policy.arn
}