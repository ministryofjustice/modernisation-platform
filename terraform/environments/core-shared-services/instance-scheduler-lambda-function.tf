module "instance_scheduler" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  #checkov:skip=CKV_AWS_173 "These lambda envvars aren't sensitive and don't need a cmk. Default AWS KMS key is sufficient"
  source                         = "github.com/ministryofjustice/modernisation-platform-terraform-lambda-function?ref=5a3c02a071519986a0ae415168fb4f9d3fb7970f" #v3.0.0
  application_name               = local.application_name
  tags                           = local.tags
  description                    = "Lambda to automatically start and stop instances on member accounts"
  role_name                      = "InstanceSchedulerLambdaFunctionPolicy"
  policy_json                    = data.aws_iam_policy_document.instance-scheduler-lambda-function-policy.json
  policy_json_attached           = true
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

  sns_topic_on_failure = aws_sns_topic.on_failure.arn
  sns_topic_on_success = aws_sns_topic.on_success.arn

}

## BEGIN: Stop trigger for Instance Scheduler Lambda Function

resource "aws_scheduler_schedule" "instance_scheduler_weekly_stop_at_night" {
  #checkov:skip=CKV_AWS_297 "KMS encryption not required at present"
  name        = "instance_scheduler_weekly_stop_at_night"
  description = "Call Instance Scheduler with Stop action at 9:00 pm (BST) every Monday through Friday"
  group_name  = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression          = "cron(0 21 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/London"
  target {
    arn      = module.instance_scheduler.lambda_function_arn
    role_arn = aws_iam_role.lambda_invoke_role_policy.arn
    input = jsonencode(
      {
        action = "Stop"
      }
    )
  }
}

## END: Stop trigger for Instance Scheduler Lambda Function

## BEGIN: Start trigger for Instance Scheduler Lambda Function

resource "aws_scheduler_schedule" "instance_scheduler_weekly_start_in_the_morning" {
  #checkov:skip=CKV_AWS_297 "KMS encryption not required at present"
  name        = "instance_scheduler_weekly_start_in_the_morning"
  description = "Call Instance Scheduler with Start action at 6:00 am (BST) every Monday through Friday"
  group_name  = "default"
  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression          = "cron(0 6 ? * MON-FRI *)"
  schedule_expression_timezone = "Europe/London"
  target {
    arn      = module.instance_scheduler.lambda_function_arn
    role_arn = aws_iam_role.lambda_invoke_role_policy.arn
    input = jsonencode(
      {
        action = "Start"
      }
    )
  }
}

## END: Start trigger for Instance Scheduler Lambda Function

# sns topics that are the instance scheduler lambda function's destination configuration
# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "on_failure" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "instance-scheduler-event-notification-topic-on-failure"
}

# tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "on_success" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "instance-scheduler-event-notification-topic-on-success"
}

# link the sns topics to the pagerduty service
module "pagerduty_core_alerts" {
  depends_on = [
    aws_sns_topic.on_failure, aws_sns_topic.on_success
  ]
  source                    = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=0179859e6fafc567843cd55c0b05d325d5012dc4" # v2.0.0
  sns_topics                = [aws_sns_topic.on_failure.name, aws_sns_topic.on_success.name]
  pagerduty_integration_key = local.pagerduty_integration_keys["core_alerts_cloudwatch"]
}

resource "aws_cloudwatch_metric_alarm" "instance_scheduler_has_errors" {
  alarm_name        = "instance-scheduler-run-with-errors"
  alarm_description = "Monitors instance-scheduller for failed invocations. It alarms when instance scheduler execution results in at least 1 error."
  alarm_actions     = [aws_sns_topic.on_failure.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "instance-scheduler-lambda-function"
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "instance_scheduler_was_throttled" {
  alarm_name        = "instance-scheduler-was-throttled"
  alarm_description = "Monitors instance-scheduller when it fails to be invoked. It alarms when instance scheduler invokation is throttled."
  alarm_actions     = [aws_sns_topic.on_failure.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = "instance-scheduler-lambda-function"
  }

  tags = local.tags
}
