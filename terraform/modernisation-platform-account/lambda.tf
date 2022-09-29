data "archive_file" "instance_scheduler_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/golang-instance-scheduler"
  output_path = "golang-instance-scheduler.zip"
}

resource "aws_lambda_function" "instance-scheduler" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  filename                       = "golang-instance-scheduler.zip"
  function_name                  = "golang-instance-scheduler"
  handler                        = "main"
  reserved_concurrent_executions = 0
  runtime                        = "go1.x"
  role                           = aws_iam_role.instance-scheduler.arn
  source_code_hash               = data.archive_file.instance_scheduler_zip.output_base64sha256
  tracing_config {
    mode = "Active"
  }
}
