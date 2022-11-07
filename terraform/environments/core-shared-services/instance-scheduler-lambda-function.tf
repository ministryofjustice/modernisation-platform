resource "aws_lambda_function" "instance-scheduler-lambda-function" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  #checkov:skip=CKV_AWS_173 "These lambda envvars aren't sensitive and don't need a cmk. Default AWS KMS key is sufficient"
  function_name                  = "instance-scheduler-lambda-function"
  reserved_concurrent_executions = 1
  image_uri                      = "${local.environment_management.account_ids[terraform.workspace]}.dkr.ecr.eu-west-2.amazonaws.com/${module.instance_scheduler_ecr_repo.ecr_repository_name}:latest"
  package_type                   = "Image"
  role                           = aws_iam_role.instance-scheduler-lambda-function.arn
  # 600 seconds = 10 minutes
  timeout = 600
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      # Initially, enabled for: sprinkler-development,cooker-development,example-development,equip-development,performance-hub-development,performance-hub-preproduction
      # Subsequently, enabled for: oasys-development,data-and-insights-wepi-development,testing-test,oasys-preproduction,tariff-development,delius-iaps-development,ppud-development,refer-monitor-development,digital-prison-reporting-development,oasys-test,threat-and-vulnerability-mgmt-development,
      "INSTANCE_SCHEDULING_SKIP_ACCOUNTS" = "xhibit-portal-development,xhibit-portal-preproduction,nomis-development,nomis-test,nomis-preproduction,apex-development,ccms-ebs-development,maatdb-development,mlra-development,"
    }
  }
}

## BEGIN: Stop trigger for Instance Scheduler Lambda Function

resource "aws_cloudwatch_event_rule" "instance_scheduler_weekly_stop_at_night" {
  name                = "instance_scheduler_weekly_stop_at_night"
  description         = "Call Instance Scheduler with Stop action at 8:00 pm (UTC) every Monday through Friday"
  schedule_expression = "cron(0 20 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "instance_scheduler_weekly_stop_at_night" {
  rule      = aws_cloudwatch_event_rule.instance_scheduler_weekly_stop_at_night.name
  target_id = "instance-scheduler-lambda-function"
  arn       = aws_lambda_function.instance-scheduler-lambda-function.arn
  input = jsonencode(
    {
      action = "Stop"
    }
  )
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_instance_scheduler_weekly_stop_at_night" {
  statement_id  = "AllowStopExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.instance-scheduler-lambda-function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_scheduler_weekly_stop_at_night.arn
}

## END: Stop trigger for Instance Scheduler Lambda Function

## BEGIN: Start trigger for Instance Scheduler Lambda Function

resource "aws_cloudwatch_event_rule" "instance_scheduler_weekly_start_in_the_morning" {
  name                = "instance_scheduler_weekly_start_in_the_morning"
  description         = "Call Instance Scheduler with Start action at 5:00 am (UTC) every Monday through Friday"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "instance_scheduler_weekly_start_in_the_morning" {
  rule      = aws_cloudwatch_event_rule.instance_scheduler_weekly_start_in_the_morning.name
  target_id = "instance-scheduler-lambda-function"
  arn       = aws_lambda_function.instance-scheduler-lambda-function.arn
  input = jsonencode(
    {
      action = "Start"
    }
  )
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_instance_scheduler_weekly_start_in_the_morning" {
  statement_id  = "AllowStartExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.instance-scheduler-lambda-function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_scheduler_weekly_start_in_the_morning.arn
}

## END: Start trigger for Instance Scheduler Lambda Function
