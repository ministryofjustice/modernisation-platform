resource "aws_lambda_function" "instance-scheduler-lambda-function" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  function_name                  = "instance-scheduler-lambda-function"
  reserved_concurrent_executions = 0
  image_uri                      = "${local.environment_management.account_ids[terraform.workspace]}.dkr.ecr.eu-west-2.amazonaws.com/${module.instance_scheduler_ecr_repo.ecr_repository_name}:latest"
  package_type                   = "Image"
  role                           = aws_iam_role.instance-scheduler-lambda-function.arn
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      "INSTANCE_SCHEDULING_ACTION"                           = "Test"
      "INSTANCE_SCHEDULING_SKIP_ACCOUNTS"                    = "oasys-development,apex-development,data-and-insights-wepi-development,xhibit-portal-development,nomis-preproduction,testing-test,oasys-preproduction,tariff-development,mlra-development,nomis-development,example-development,performance-hub-preproduction,xhibit-portal-preproduction,delius-iaps-development,performance-hub-development,ppud-development,refer-monitor-development,digital-prison-reporting-development,oasys-test,equip-development,threat-and-vulnerability-mgmt-development,nomis-test,"
    }
  }
}
