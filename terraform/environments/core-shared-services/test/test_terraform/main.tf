data "aws_lambda_function" "instance_scheduler" {
  function_name = local.function_name
}

data "aws_lambda_invocation" "instance_scheduler_invocation" {
  function_name = data.aws_lambda_function.instance_scheduler.function_name

  input = jsonencode(
    {
      action = "Test"
  })
}