# This covers the SQS and related infrastructure that allows Cortex XSIAM service to access updates to the cloudtrail logging bucket

# SQS Queue to present the logging bucket updates
resource "aws_sqs_queue" "mp_cloudtrail_log_queue" {
  name                      = "mp_cloudtrail_log_queue"
  delay_seconds             = 0       # The default is 0 but can be up to 15 minutes
  max_message_size          = 262144  # 256k which is the max size
  message_retention_seconds = 345600  # This is 4 days. The max is 14 days
  visibility_timeout_seconds = 30     # This is only useful for queues that have multiple subscribers
}

# Data to grant read access to the s3 bucket
data "aws_iam_policy_document" "sqs_s3_read_bucket_document" {
  statement {
    sid       = "S3BucketGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = [module.s3-bucket-cloudtrail.bucket.arn, "${module.s3-bucket-cloudtrail.bucket.arn}/*"] 
  }
}

# Grant access for the queue read the S3 logging bucket
resource "aws_sqs_queue_policy" "sqs_s3_read_bucket_policy" {
  queue_url = aws_sqs_queue.mp_cloudtrail_log_queue.id
  policy = data.aws_iam_policy_document.sqs_s3_read_bucket_document.json
}

# S3 bucket event notification for updates to the cloudtrail logging bucket
resource "aws_s3_bucket_notification" "logging_bucket_notification" {
  bucket = module.s3-bucket-cloudtrail-logging.bucket.bucket  
  queue {
    queue_arn = aws_sqs_queue.mp_cloudtrail_log_queue.arn
    events    = ["s3:ObjectCreated:*"]  # Events to trigger the notification
  }
}

##### IAM User Account & Resources to access the sqs queue

# Create an IAM policy document to allow access to the SQS Queue
data "aws_iam_policy_document" "sqs_queue_read_document" {
  statement {
    sid       = "SQSQueueReceiveMessages"
    effect    = "Allow"
    actions   = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues"
    ]
    resources = [aws_sqs_queue.mp_cloudtrail_log_queue.arn] 
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
  name = "cortex_xsiam_user"
}

resource "aws_iam_user_policy_attachment" "sqs_queue_read_policy_attachment" {
  user       = "cortex_xsiam_user" 
  policy_arn = aws_iam_policy.sqs_queue_read_policy.arn
}