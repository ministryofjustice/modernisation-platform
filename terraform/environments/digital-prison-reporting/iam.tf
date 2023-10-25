resource "aws_iam_role" "circleci_iam_role" {
  name = "circleci_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity",
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.circleci_oidc_provider.arn
      },
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.circleci_oidc_provider.url}:sub" = "need-to-work-out-the-subject-identifier-value"
        }
      }
    }]
  })
}


data "aws_iam_policy_document" "circleci_iam_policy" {
  statement {
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::dpr-artifact-store-development/*"]
  }
}

resource "aws_iam_policy" "circleci_iam_policy" {
  name = "circleci_iam_policy"
  description = "Policy for CircleCI"
  policy = data.aws_iam_policy_document.circleci_iam_policy.json
}


resource "aws_iam_policy_attachment" "circleci_policy_attachment" {
  policy_arn = aws_iam_policy.circleci_iam_policy.arn
  roles      = [aws_iam_role.circleci_iam_role.name]
  name       = "circleci_policy_attachment"
}