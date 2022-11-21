#------------------------------------------------------------------------------
# Patching POC
#------------------------------------------------------------------------------

###### IAM  #####

data "aws_iam_policy_document" "ssm-admin-policy-doc" {
  statement {
    actions = ["s3:*",
                "ec2:*",
                "ssm:*",
                "cloudwatch:*",
                "cloudformation:*",
                "iam:*",
                "lambda:*"
            ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "ssm-admin-iam-policy" {
  name        = "ssm-admin-iam-policy"
  description = "test"
  path        = "/"
  policy = data.aws_iam_policy_document.ssm-admin-policy-doc.json
}

resource "aws_iam_role" "ssm-admin-role" {
  name        = "ssm-admin-role-new"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "iam.amazonaws.com"
        ]
      },
      "Action": [
              "sts:AssumeRole"
      ]
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "ssm-admin-automation" {
  role       = aws_iam_role.ssm-admin-role.name
  policy_arn = aws_iam_policy.ssm-admin-iam-policy.arn
}

###### Resource Group  #####

resource "aws_resourcegroups_group" "ssm_patch_group_dev" {
  name = "${local.application_name}-patch-group"
  resource_query {
    query = <<JSON
{
	"ResourceTypeFilters": [
		"AWS::EC2::Instance"
	],
	"TagFilters": [{
		"Key": "Patching",
		"Values": ["yes", "true"]
	}]
}
JSON
  }
}

####### Approval rule #####
#
#resource "aws_ssm_patch_baseline" "patch-baseline-poc" {
#  name             = "${local.application_name}-baseline"
#  operating_system = local.operating_system
#
#  approval_rule {
#    approve_after_days = 7
#    compliance_level   = "HIGH"
#
#    patch_filter {
#      key    = "CLASSIFICATION"
#      values = ["Security", "Bugfix"]
#    }
#  }
#}

###### ssm maintenance window #####

resource "aws_ssm_maintenance_window" "ssm-maintenance-window" {
  name     = "${local.application_name}-maintenance-window"
  schedule = "cron(45 15 ? * MON *)"
  duration = 24
  cutoff   = 10
}

###### ssm maintenance target #####

resource "aws_ssm_maintenance_window_target" "ssm-targets" {
  window_id     = aws_ssm_maintenance_window.ssm-maintenance-window.id
  name          = "maintenance-window-target"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patching"
    values = ["yes"]
  }
}

###### ssm automation task #####

resource "aws_ssm_maintenance_window_task" "ssm-maintenance-window-automation-task" {
  name            = "${local.application_name}-automation-patching-task"
  max_concurrency = 20
  max_errors      = 10
  priority        = 1
  task_type       = "AUTOMATION"
  task_arn        = "AWS-PatchInstanceWithRollback"
  window_id       = aws_ssm_maintenance_window.ssm-maintenance-window.id
  service_role_arn = aws_iam_role.ssm-admin-role.arn

  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.ssm-targets.*.id
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "InstanceId"
        values = ["{{RESOURCE_ID}}"]
      }
      parameter {
        name   = "ReportS3Bucket"
        values = ["sprinkler-patching-logs"]
      }
    }
  }
}

###### s3 Bucket Patch Logs #####

resource "aws_s3_bucket" "patching-log-bucket" {
  bucket = "${local.application_name}-patching-logs"

  tags = {
    name        = "${local.application_name}-patching-logs"
    Environment = "${local.environment}"
  }
}