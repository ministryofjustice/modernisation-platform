#------------------------------------------------------------------------------
# Patching POC
#------------------------------------------------------------------------------

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

resource "aws_ssm_maintenance_window" "poc-maintenance-window" {
  name      = "${local.application_name}-maintenance-window"
  schedule = "cron(0 16 ? * TUE *)"
  duration = 3
  cutoff   = 1
}

###### s3 Bucket Patch Logs #####

resource "aws_s3_bucket" "patching-log-bucket" {
  bucket = "${local.application_name}-patching-logs"

  tags = {
    name        = "${local.application_name}-patching-logs"
    Environment = "${local.environment}"
  }
}