# IAM role with a trust policy that allows the Lambda service to assume this role.
resource "aws_iam_role" "secrets_manager_execution_role" {
  name = "secrets_manager_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Defines an IAM policy named that grants various permissions to interact with AWS Secrets Manager.
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerPolicy"
  description = "Policy to access AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Effect   = "Allow",
        Resource = "*",
      }
    ]
  })
}

# Attaches the Secrets Manager policy to the IAM role created for the Lambda function.
resource "aws_iam_role_policy_attachment" "secrets_manager_policy_attachment" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = aws_iam_role.secrets_manager_execution_role.name
}
