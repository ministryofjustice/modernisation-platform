module "instance_scheduler" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  #checkov:skip=CKV_AWS_173 "These lambda envvars aren't sensitive and don't need a cmk. Default AWS KMS key is sufficient"
  source                         = "github.com/ministryofjustice/modernisation-platform-terraform-lambda-function?ref=20e0d9e27402d1e012159a41b474da908d74941b" #v2.0.0
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
    # Only nomis-preproduction is a member account having the InstanceSchedulerAccess role
    "INSTANCE_SCHEDULING_SKIP_ACCOUNTS" = "nomis-preproduction,mi-platform-development,analytical-platform-data-development,bichard7-test-next,bichard7-sandbox-shared,core-vpc-development,bichard7-sandbox-a,bichard7-shared,bichard7-test-current,bichard7-sandbox-c,core-vpc-sandbox,core-vpc-test,bichard7-sandbox-b,core-vpc-preproduction,core-sandbox-dev,"
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
  schedule_expression = "cron(0 21 ? * MON-FRI *)" ## Edited to work with daylight savings, will need changing March 2024.
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
  schedule_expression = "cron(0 6 ? * MON-FRI *)" ## Edited to work with daylight savings, will need changing March 2024.
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

# sns topics that are the instance scheduler lambda function's destination configuration
resource "aws_sns_topic" "on_failure" {
  name = "instance-scheduler-event-notification-topic-on-failure"
}

resource "aws_sns_topic" "on_success" {
  name = "instance-scheduler-event-notification-topic-on-success"
}

# link the sns topics to the pagerduty service
module "pagerduty_core_alerts" {
  depends_on = [
    aws_sns_topic.on_failure, aws_sns_topic.on_success
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=v2.0.0"
  sns_topics                = [aws_sns_topic.on_failure.name, aws_sns_topic.on_success.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["operations_cloudwatch"]
}