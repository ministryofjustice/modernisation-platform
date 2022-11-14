output "execution_response" {
  value = jsondecode(data.aws_lambda_invocation.instance_scheduler_invocation.result)
}

output "function_name" {
    value = data.aws_lambda_function.instance_scheduler.function_name
}

output "execution_result" {
  value = jsondecode(data.aws_lambda_invocation.instance_scheduler_invocation.result)["statusCode"]
}