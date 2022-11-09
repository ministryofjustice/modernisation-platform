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
  schedule = "cron(0 16 ? * TUE *)"
  duration = 3
  cutoff   = 1
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
resource "aws_ssm_maintenance_window_task" "ssm-maintenance-window-task" {
  name            = "${local.application_name}-patching-task"
  max_concurrency = 2
  max_errors      = 1
  priority        = 1
  task_arn        = "AWS-PatchAsgInstance"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.ssm-maintenance-window.id


  targets {
    key    = "WindowTargetIds"
    values = aws_ssm_maintenance_window_target.ssm-targets.*.id
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket = "${local.application_name}-patching-logs"
      timeout_seconds  = 600
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

###### ssm automation doc #####

resource "aws_ssm_document" "patching-automation" {
  name          = "${local.application_name}-patching-doc"
  document_type = "Automation"

  content = <<DOC
{
	"description": "Systems Manager Automation - Patch instances in an Auto Scaling Group",
	"schemaVersion": "0.3",
	"assumeRole": "{{AutomationAssumeRole}}",
	"parameters": {
		"InstanceId": {
			"type": "String",
			"description": "(Required) ID of the Instance to patch. Only specify when not running from Maintenance Windows."
		},
		"WaitForReboot": {
			"type": "String",
			"description": "(Optional) How long Automation should sleep for, to allow a patched instance to reboot",
			"default": "PT5M"
		},
		"WaitForInstance": {
			"type": "String",
			"description": "(Optional) How long Automation should sleep for, to allow the instance come back into service",
			"default": "PT2M"
		},
		"LambdaRoleArn": {
			"default": "",
			"type": "String",
			"description": "(Optional) The ARN of the role that allows Lambda created by Automation to perform the actions on your behalf. If not specified a transient role will be created to execute the Lambda function."
		},
		"AutomationAssumeRole": {
			"type": "String",
			"description": "(Optional) The ARN of the role that allows Automation to perform the actions on your behalf.",
			"default": ""
		}
	},
	"mainSteps": [{
			"name": "createPatchGroupTags",
			"action": "aws:createTags",
			"maxAttempts": 1,
			"onFailure": "Continue",
			"inputs": {
				"ResourceType": "EC2",
				"ResourceIds": [
					"{{InstanceId}}"
				],
				"Tags": [{
					"Key": "AutoPatchInstanceInASG",
					"Value": "InProgress"
				}]
			}
		},
		{
			"name": "EnterStandby",
			"action": "aws:executeAutomation",
			"maxAttempts": 1,
			"timeoutSeconds": 300,
			"onFailure": "Abort",
			"inputs": {
				"DocumentName": "AWS-ASGEnterStandby",
				"RuntimeParameters": {
					"InstanceId": [
						"{{InstanceId}}"
					],
					"LambdaRoleArn": [
						"{{LambdaRoleArn}}"
					],
					"AutomationAssumeRole": [
						"{{AutomationAssumeRole}}"
					]
				}
			}
		},
		{
			"name": "installMissingOSUpdates",
			"action": "aws:runCommand",
			"maxAttempts": 1,
			"onFailure": "Continue",
			"isCritical": true,
			"inputs": {
				"DocumentName": "AWS-RunPatchBaseline",
				"InstanceIds": [
					"{{InstanceId}}"
				],
				"Parameters": {
					"Operation": "Install"
				}
			}
		},
		{
			"name": "SleepToCompleteInstall",
			"action": "aws:sleep",
			"inputs": {
				"Duration": "{{WaitForReboot}}"
			}
		},
		{
			"name": "ExitStandby",
			"action": "aws:executeAutomation",
			"maxAttempts": 1,
			"timeoutSeconds": 300,
			"onFailure": "Abort",
			"inputs": {
				"DocumentName": "AWS-ASGExitStandby",
				"RuntimeParameters": {
					"InstanceId": [
						"{{InstanceId}}"
					],
					"LambdaRoleArn": [
						"{{LambdaRoleArn}}"
					],
					"AutomationAssumeRole": [
						"{{AutomationAssumeRole}}"
					]
				}
			}
		},
		{
			"name": "CompletePatchGroupTags",
			"action": "aws:createTags",
			"maxAttempts": 1,
			"onFailure": "Continue",
			"inputs": {
				"ResourceType": "EC2",
				"ResourceIds": [
					"{{InstanceId}}"
				],
				"Tags": [{
					"Key": "AutoPatchInstanceInASG",
					"Value": "Completed"
				}]
			}
		},
		{
			"name": "SleepBeforeNextInstance",
			"action": "aws:sleep",
			"inputs": {
				"Duration": "{{WaitForInstance}}"
			}
		}
	]
}
DOC
}


###### s3 Bucket Patch Logs #####

resource "aws_s3_bucket" "patching-log-bucket" {
  bucket = "${local.application_name}-patching-logs"

  tags = {
    name        = "${local.application_name}-patching-logs"
    Environment = "${local.environment}"
  }
}