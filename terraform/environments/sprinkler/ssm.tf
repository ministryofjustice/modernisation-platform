#------------------------------------------------------------------------------
# Patching POC
#------------------------------------------------------------------------------

resource "aws_iam_role" "ssm_ec2_instance_role" {
  name = "service-ec2-ssm"
  assume_role_policy = ""
}

resource "aws_iam_instance_profile" "poc_service_ssm" {
  name = "service_ec2_ssm"
  role = aws_iam_role.ssm_ec2_instance_role.name
}


resource "aws_resourcegroups_group" "ssm_patch_group_dev" {
  name = "poc"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    'AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "Patching",
      "Values": ["yes", "true"]
    }
  ]
}
JSON
  }
}

resource "aws_ssm_patch_baseline" "patch-poc" {
  name             = "patch-baseline"

  approval_rule {
    approve_after_days = 7
    compliance_level   = "HIGH"

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["CriticalUpdates", "SecurityUpdates", "Updates"]
    }
  }
}