#------------------------------------------------------------------------------
# Patching POC
#------------------------------------------------------------------------------

###### IAM #####


data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_ec2_instance_role" {
  name               = "service-ec2-ssm"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_instance_profile" "ssm_ec2_instance_profile" {
  name = "service_ec2_ssm"
  role = aws_iam_role.ssm_ec2_instance_role.name
}


###### IAM 2 #####

data "aws_iam_policy_document" "ssm-admin-policy-doc" {
  statement {
    actions = [
      "sts:AssumeRole",
      "ec2:*",
      "ssm:*",
      "iam:*",
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
  description = "test - access to source and destination S3 bucket"

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
      "Action": "sts:AssumeRole"
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

###### Approval rule #####

resource "aws_ssm_patch_baseline" "patch-baseline-poc" {
  name             = "${local.application_name}-baseline"
  operating_system = local.operating_system

  approval_rule {
    approve_after_days = 7
    compliance_level   = "HIGH"

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix"]
    }
  }
}

###### ssm maintenance window #####


resource "aws_ssm_maintenance_window" "ssm-maintenance-window" {
  name     = "${local.application_name}-maintenance-window"
  schedule = "cron(07 09 ? * MON *)"
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




###### ssm maintenance task #####
resource "aws_ssm_maintenance_window_task" "ssm-maintenance-window-command-task" {
  name            = "${local.application_name}-command-patching-task"
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.ssm-maintenance-window.id


  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.ssm-targets.*.id
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket = "${local.application_name}-patching-logs"
      timeout_seconds  = 6000
      service_role_arn = aws_iam_role.ssm_ec2_instance_role.arn

      # Install will perform a scan followed by an install on any missing packages. This is completed with a system
      # rebot. NOTE: Scan only can be used to output results to S3 log bucket and does not cause a rebot.
      parameter {
        name   = "Operation"
        values = ["Scan"]
      }
    }
  }
}


resource "aws_ssm_maintenance_window_task" "ssm-maintenance-window-automation-task" {
  name            = "${local.application_name}-automation-patching-task"
  max_concurrency = 20
  max_errors      = 10
  priority        = 1
  task_type       = "AUTOMATION"
  task_arn        = "AWS-PatchAsgInstance"
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
        values = aws_ssm_maintenance_window_target.ssm-targets.*.id
      }
#      parameter {
#        name   = "ReportS3Bucket"
#        values = ["${local.application_name}-patching-logs"]
#      }
#      parameter {
#        name   = "AutomationAssumeRole"
#        values = [aws_iam_role.ssm_ec2_instance_role.arn]
#      }

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