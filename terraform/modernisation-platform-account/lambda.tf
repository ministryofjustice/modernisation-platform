resource "aws_lambda_function" "instance-scheduler" {
  filename      = "golang_instance_scheduler.zip"
  function_name = "golang-instance-scheduler"
  handler       = "main"
  runtime       = "go1.x"
  role          = aws_iam_role.instance-scheduler.arn
}