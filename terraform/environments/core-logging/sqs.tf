# This covers the SQS and related infrastructure that allows Cortex XSIAM service to access updates to the cloudtrail logging bucket

# SQS Queue to present the logging bucket updates
resource "aws_sqs_queue" "mp_cloudtrail_log_queue" {
  name                              = "mp_cloudtrail_log_queue"
  kms_master_key_id                 = "alias/s3-logging-cloudtrail" # We reuse the S3 bucket key
  kms_data_key_reuse_period_seconds = 300
  delay_seconds                     = 0      # The default is 0 but can be up to 15 minutes
  max_message_size                  = 262144 # 256k which is the max size
  message_retention_seconds         = 345600 # This is 4 days. The max is 14 days
  visibility_timeout_seconds        = 30     # This is only useful for queues that have multiple subscribers
}

# S3 bucket event notification for updates to the cloudtrail logging bucket
resource "aws_s3_bucket_notification" "logging_bucket_notification" {
  bucket = module.s3-bucket-cloudtrail-logging.bucket.bucket
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