# Terraform's AWS provider does not provide a mechanism to query the ecr repository.
#
# We use an external data source, which can run any program that returns valid JSON, to run the AWS
# cli manually, which will produce a JSON in the following format:
#
#   {
#     "tags": "[\"1.0.0.1166\"]"
#   }
#
# See also: https://github.com/hashicorp/terraform-provider-aws/issues/12798
data "external" "tags_of_most_recently_pushed_image" {
  program = [
    "aws", "ecr", "describe-images",
    "--repository-name", module.instance_scheduler_ecr_repo.ecr_repository_name,
    "--query", "{\"tags\": to_string(sort_by(imageDetails,& imagePushedAt)[-1].imageTags)}",
  ]
}

resource "aws_lambda_function" "instance-scheduler-lambda-function" {
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  function_name                  = "instance-scheduler-lambda-function"
  handler                        = "main"
  reserved_concurrent_executions = 0
  runtime                        = "go1.x"
  image_uri                      = "${module.instance_scheduler_ecr_repo.ecr_repository_name}:${tags_of_most_recently_pushed_image[0]}"
  package_type                   = "Image"
  role                           = aws_iam_role.instance-scheduler-lambda-function.arn
}