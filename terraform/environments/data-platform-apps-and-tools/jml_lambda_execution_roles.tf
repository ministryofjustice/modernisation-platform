# IAM role with a trust policy that allows the Lambda service to assume this role. 
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

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
#Creates a Lambda function named using the IAM role created earlier. 
resource "aws_lambda_function" "jml_lambda_execution_function" {
  function_name = "jml_lambda_execution_function"
  handler       = "handler"
  runtime       = "python3.11"
  filename      = "src/var/task"
  role          = aws_iam_role.lambda_execution_role.arn
}
# Defines an IAM policy named that grants various permissions to interact with CloudWatch Logs.
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "CloudWatchLogsPolicy"
  description = "Policy to access CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudwatch:GenerateQuery"
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "secretsmanager:GetSecretValue",
         "secretsmanager:DescribeSecret",
         "secretsmanager:ListSecrets"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:iam::${local.environment_management.account_ids["analytical-platform-data-production"]}:log-group:/aws/events/auth0/*",
      }
    ]
  })
}
# Attaches the CloudWatch Logs policy to the IAM role created for the Lambda function.
resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}