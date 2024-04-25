# VPC Flow Log: configure an IAM role
resource "aws_iam_role" "vpc_flow_log" {
  name               = "AWSVPCFlowLog"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_role_policy.json
}

# VPC Flow Log: assume role policy
data "aws_iam_policy_document" "vpc_flow_log_assume_role_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}