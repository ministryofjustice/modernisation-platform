data "aws_iam_policy_document" "assumable-by-modernisation-platform" {
  version = "2012-10-17"

  statement {
    sid    = "AllowModernisationPlatformToAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.modernisation_platform_account.id}:root"]
    }
  }
}
