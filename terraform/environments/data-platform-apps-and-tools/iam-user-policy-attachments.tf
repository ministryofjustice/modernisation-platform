resource "aws_iam_user_policy_attachment" "airflow_ses" {
  user       = module.airflow_iam_user.iam_user_name
  policy_arn = module.airflow_ses_policy.arn
}
