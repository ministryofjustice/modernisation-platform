data "aws_iam_policy_document" "pagerduty" {
  statement {
    sid    = "ReadOnlyFromModernisationPlatformOU"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["AWS"]
    }
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:GetResourcePolicy", "secretsmanager:DescribeSecret"]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      values   = ["o-b2fpbzyd95/*/ou-j1kx-qxsrh1gv/*"]
      variable = "aws:PrincipalOrgPaths"
    }
  }
}