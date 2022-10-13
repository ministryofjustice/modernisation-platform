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
  provider = aws
  program = [
    "aws", "ecr", "describe-images",
    "--region", "eu-west-2",
    "--repository-name", module.instance_scheduler_ecr_repo.ecr_repository_name,
    "--query", "{\"tags\": to_string(sort_by(imageDetails,& imagePushedAt)[-1].imageTags)}",
  ]
}

output "tags" {
  description = ""
  value       = jsondecode(data.external.tags_of_most_recently_pushed_image.result.tags)
}
