resource "aws_sqs_queue" "logging" {
  for_each                = local.cortex_logging_buckets
  name_prefix             = "${local.application_name}-${each.key}"
  sqs_managed_sse_enabled = true # Using managed encryption
  tags                    = local.tags
}

resource "aws_sqs_queue_policy" "logging" {
  for_each  = local.cortex_logging_buckets
  policy    = data.aws_iam_policy_document.logging-sqs[each.key].json
  queue_url = aws_sqs_queue.logging[each.key].url
}

data "aws_iam_policy_document" "logging-sqs" {
  for_each = local.cortex_logging_buckets
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.logging[each.key].arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.logging[each.key].arn]
    }
  }
}

resource "aws_s3_bucket_notification" "logging" {
  for_each = local.cortex_logging_buckets
  bucket   = aws_s3_bucket.logging[each.key].id
  queue {
    queue_arn = aws_sqs_queue.logging[each.key].arn
    events    = ["s3:ObjectCreated:*"] # Events to trigger the notification
  }
}

