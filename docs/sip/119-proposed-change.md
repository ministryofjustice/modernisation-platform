# SIP 119 proposed code change

This is the code-level proposal required by the POC. It is intentionally not applied from this repository because the account alarm resources are owned by `ministryofjustice/modernisation-platform-terraform-baselines`.

The proposal defaults to disabled. The notification action shown below assumes the existing low-priority route; the team must confirm that decision before implementation.

## Baseline module interface

Add to the root `variables.tf`:

```hcl
variable "enable_iam_user_creation_alarm" {
  description = "Enable alerting for IAM user creation outside approved automation roles."
  type        = bool
  default     = false
}
```

Pass it to `module "securityhub-alarms"` in the root `main.tf`:

```hcl
enable_iam_user_creation_alarm = var.enable_iam_user_creation_alarm
```

Add the following variables to `modules/securityhub-alarms/variables.tf`:

```hcl
variable "enable_iam_user_creation_alarm" {
  description = "Enable alerting for IAM user creation outside approved automation roles."
  type        = bool
  default     = false
}

variable "iam_user_creation_metric_filter_name" {
  type    = string
  default = "iam-user-creation-not-by-automation"
}

variable "iam_user_creation_alarm_name" {
  type    = string
  default = "iam-user-creation-by-untrusted-role"
}
```

Give each workspace a distinct metric and alarm name in the root `main.tf`:

```hcl
iam_user_creation_metric_filter_name = "iam-user-creation-not-by-automation-${local.workspace_name}"
iam_user_creation_alarm_name         = "iam-user-creation-by-untrusted-role-${local.workspace_name}"
```

## IAM event filter and alarm

Add to `modules/securityhub-alarms/iam_alerts.tf` beside the existing IAM user deletion control:

```hcl
resource "aws_cloudwatch_log_metric_filter" "iam_user_creation_not_by_automation" {
  count = var.enable_iam_user_creation_alarm ? 1 : 0

  name           = var.iam_user_creation_metric_filter_name
  log_group_name = var.cloudtrail_log_group_name
  pattern        = "{ $.eventSource = \"iam.amazonaws.com\" && $.eventName = \"CreateUser\" && ${local.automation_role_filter} }"

  metric_transformation {
    name      = var.iam_user_creation_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_user_creation_by_untrusted_role" {
  count = var.enable_iam_user_creation_alarm ? 1 : 0

  alarm_name        = var.iam_user_creation_alarm_name
  alarm_description = "Monitors for IAM user creation outside approved automation roles."
  alarm_actions     = local.low_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = var.iam_user_creation_metric_filter_name
  namespace           = "LogMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  tags = var.tags

  depends_on = [aws_cloudwatch_log_metric_filter.iam_user_creation_not_by_automation]
}
```

Before merging, validate the filter against representative CloudTrail events for each account type. In particular, confirm that `local.automation_role_filter` excludes only the intended roles.

## Consumer opt-in

After releasing the baseline module and updating its pinned version in `modernisation-platform`, pass the feature flag from `terraform/environments/bootstrap/secure-baselines/main.tf`:

```hcl
enable_iam_user_creation_alarm = contains(
  [
    "sprinkler-development",
  ],
  terraform.workspace,
)
```

Do not enable the variable in `terraform/modernisation-platform-account/baselines.tf` during the POC.

## Required tests

The baseline module test suite should prove that:

- The filter and alarm are absent when the flag is omitted or false.
- They are present when the flag is true.
- The alarm references the metric created by the filter.
- Missing data is treated as non-breaching.
- The selected SNS route matches the approved priority.
- Representative manual `CreateUser` events match.
- Representative events from every trusted automation role do not match.
- The existing `DeleteUser` filter and alarm remain unchanged.

The consumer plan for `sprinkler-development` must show only the expected filter and alarm before anyone approves deployment.
