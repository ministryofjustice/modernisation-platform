resource "aws_lambda_function" "instance-scheduler-lambda-function" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  function_name                  = "instance-scheduler-lambda-function"
  handler                        = "main"
  reserved_concurrent_executions = 0
  runtime                        = "go1.x"
  image_uri                      = "${local.environment_management.account_ids[terraform.workspace]}.dkr.ecr.eu-west-2.amazonaws.com/${module.instance_scheduler_ecr_repo.ecr_repository_name}:latest"
  package_type                   = "Image"
  role                           = aws_iam_role.instance-scheduler-lambda-function.arn
  tracing_config {
    mode = "Active"
  }
}
