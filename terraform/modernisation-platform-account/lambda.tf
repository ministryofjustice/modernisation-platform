data "archive_file" "instance_scheduler_zip" {
  type        = "zip"
  source_dir  = "./lambda/golang-instance-scheduler"
  output_path = "golang_instance_scheduler.zip"
}

resource "aws_lambda_function" "instance-scheduler" {
  filename         = "golang-instance-scheduler.zip"
  function_name    = "golang-instance-scheduler"
  handler          = "main"
  runtime          = "go1.x"
  role             = aws_iam_role.instance-scheduler.arn
  source_code_hash = data.archive_file.instance_scheduler_zip.output_base64sha256
}