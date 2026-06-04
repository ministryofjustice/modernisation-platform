# Suppress EC2.23 - EC2 Transit Gateways should not automatically accept VPC attachment requests
# Rationale: We have implemented CloudWatch monitoring as a compensating control to detect
# unauthorized attachment creation. Auto-accept is required for our automated VPC deployment workflow.
# Risk acceptance documented in team discussion 2026-01-15.

resource "aws_securityhub_standards_control" "ec2_23_tgw_auto_accept" {
  standards_control_arn = "arn:aws:securityhub:eu-west-2:${data.aws_caller_identity.current.account_id}:control/aws-foundational-security-best-practices/v/1.0.0/EC2.23"
  control_status        = "DISABLED"
  disabled_reason       = "Compensating control: CloudWatch monitoring detects unauthorized TGW attachments. Auto-accept required for automated infrastructure deployment."
}
