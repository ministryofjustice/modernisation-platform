#tfsec:ignore:AWS078 tfsec:ignore:aws-ecr-repository-customer-key
resource "aws_ecr_repository" "ecr_repo" {
  #checkov:skip=CKV_AWS_51:Skip Tag Mutable requirement we want tags to be overwritten   
  name                 = "${var.app_name}-ecr-repo"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.tags_common,
    {
      Name = "${var.app_name}-ecr-repo"
    }
  )
}

data "aws_iam_policy_document" "ecr_repo_policy" {
  statement {
    sid    = "AllowPush"
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:DescribeImages"
    ]
    principals {
      type        = "AWS"
      identifiers = var.push_principals
    }
  }

  statement {
    sid    = "AllowPull"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    principals {
      type        = "AWS"
      identifiers = var.pull_principals
    }
  }

  dynamic "statement" {
    for_each = length(var.enable_retrieval_policy_for_lambdas) > 0 ? [1] : []

    content {
      sid    = "LambdaECRImageRetrievalPolicy"
      effect = "Allow"
      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:SetRepositoryPolicy",
        "ecr:DeleteRepositoryPolicy",
        "ecr:GetRepositoryPolicy"
      ]
      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
      condition {
        test     = "StringLike"
        variable = "aws:sourceArn"
        values   = var.enable_retrieval_policy_for_lambdas
      }
    }
  }
}

resource "aws_ecr_repository_policy" "ecr_repository_policy" {
  repository = aws_ecr_repository.ecr_repo.name
  policy     = data.aws_iam_policy_document.ecr_repo_policy.json
}
