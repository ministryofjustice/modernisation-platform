data "aws_iam_role" "vpc-flow-log" {
  name = "AWSVPCFlowLog"
}

# Create IAM role and instance profile for image builder
# Instance profile gets associated to the image builder Infrastructure Configuration resource
data "aws_iam_policy" "image_builder_managed_policies" {
  for_each = toset([
    "EC2InstanceProfileForImageBuilder",
    "AmazonSSMManagedInstanceCore"
  ])
  name = each.key
}

data "aws_iam_policy_document" "image_builder_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "image_builder" {
  name                = "image-builder"
  assume_role_policy  = data.aws_iam_policy_document.image_builder_assume_policy.json
  managed_policy_arns = [for k in data.aws_iam_policy.image_builder_managed_policies : k.arn]
}

resource "aws_iam_instance_profile" "image_builder" {
  name = "image-builder"
  role = aws_iam_role.image_builder.name
}

#read only role for health check
module "iam_assumable_roles" {
  source               = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"
  version              = "~> 2.0"
  max_session_duration = 43200

  # Read-only role
  create_readonly_role       = true
  readonly_role_name         = "readonly"
  readonly_role_requires_mfa = true

  # Allow created users to assume these roles
  trusted_role_arns = [
    data.aws_caller_identity.modernisation-platform.account_id
  ]
}
