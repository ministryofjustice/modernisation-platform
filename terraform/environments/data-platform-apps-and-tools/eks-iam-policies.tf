data "aws_iam_policy_document" "openmetadata_airflow" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::593291632749:role/openmetadata-airflow20230623105404064900000001", // analytical-platform-data-production
      "arn:aws:iam::013433889002:role/openmetadata-airflow20230623105404064900000001"  // data-platform-development
    ]
  }
}

module "openmetadata_airflow_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.0"

  name_prefix = "openmetadata-airflow"

  policy = data.aws_iam_policy_document.openmetadata_airflow.json
}
