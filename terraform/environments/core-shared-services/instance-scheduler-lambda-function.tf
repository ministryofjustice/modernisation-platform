# resource "aws_lambda_function" "instance-scheduler-lambda-function" {
#   #checkov:skip=CKV_AWS_116
#   #checkov:skip=CKV_AWS_117
#   #checkov:skip=CKV_AWS_272 "Code signing not required"
#   #checkov:skip=CKV_AWS_173 "These lambda envvars aren't sensitive and don't need a cmk. Default AWS KMS key is sufficient"
#   function_name                  = "instance-scheduler-lambda-function"
#   reserved_concurrent_executions = 1
#   image_uri                      = "${local.environment_management.account_ids[terraform.workspace]}.dkr.ecr.eu-west-2.amazonaws.com/${module.instance_scheduler_ecr_repo.ecr_repository_name}:latest"
#   package_type                   = "Image"
#   role                           = aws_iam_role.instance-scheduler-lambda-function.arn
#   # 600 seconds = 10 minutes
#   timeout = 600
#   tracing_config {
#     mode = "Active"
#   }
#   environment {
#     variables = {
#       # Initially, enabled for: sprinkler-development,cooker-development,example-development,equip-development,performance-hub-development,performance-hub-preproduction
#       # Subsequently, enabled for: oasys-development,data-and-insights-wepi-development,testing-test,oasys-preproduction,tariff-development,delius-iaps-development,ppud-development,refer-monitor-development,digital-prison-reporting-development,oasys-test,threat-and-vulnerability-mgmt-development,apex-development,ccms-ebs-development,maatdb-development,mlra-development,xhibit-portal-development,xhibit-portal-preproduction,nomis-development,nomis-test,
#       "INSTANCE_SCHEDULING_SKIP_ACCOUNTS" = "nomis-preproduction,"
#     }
#   }
# }

module "instance_scheduler" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  #checkov:skip=CKV_AWS_173 "These lambda envvars aren't sensitive and don't need a cmk. Default AWS KMS key is sufficient"
  source                         = "github.com/ministryofjustice/modernisation-platform-terraform-lambda-function?ref=v1.0.0"
  application_name               = local.application_name
  tags                           = local.tags
  description                    = "Lambda to automatically start and stop instances on member accounts"
  role_name                      = "InstanceSchedulerLambdaFunctionPolicy"
  policy_json                    = data.aws_iam_policy_document.instance-scheduler-lambda-function-policy.json
  function_name                  = "instance-scheduler-lambda-function"
  create_role                    = true
  reserved_concurrent_executions = 1
  additional_trust_roles         = [module.github-oidc.github_actions_role]
  environment_variables = {
    "INSTANCE_SCHEDULING_SKIP_ACCOUNTS" = "nomis-preproduction,"
  }
  image_uri    = "${local.environment_management.account_ids[terraform.workspace]}.dkr.ecr.eu-west-2.amazonaws.com/${module.instance_scheduler_ecr_repo.ecr_repository_name}:latest"
  timeout      = 600
  tracing_mode = "Active"

  allowed_triggers = {
    AllowStopExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.instance_scheduler_weekly_stop_at_night.arn
    }
    AllowStartExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.instance_scheduler_weekly_start_in_the_morning.arn
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
  arn       = module.instance_scheduler.lambda_function_arn
  input = jsonencode(
    {
      action = "Stop"
    }
  )
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
  arn       = module.instance_scheduler.lambda_function_arn
  input = jsonencode(
    {
      action = "Start"
    }
  )
}

## END: Start trigger for Instance Scheduler Lambda Function
