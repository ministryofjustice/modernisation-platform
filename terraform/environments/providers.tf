# As of 2020-09-29, there is an open issue regarding dynamic providers (hashicorp/terraform#24476).
# Therefore, we need to generate a file that defines providers as "static" blocks.
#
# This generates a file for additional providers, based on accounts created through the "environments" module
# in environments.tf.
#
# It should not be committed as it holds account IDs.
locals {
  providers_file = templatefile("providers.tmpl", { accounts : module.environments.environment_account_ids })
}

resource "aws_s3_bucket_object" "modernisation-platform-providers" {
  provider     = aws.modernisation-platform
  bucket       = "modernisation-platform-terraform-state"
  key          = "providers-generated.tf"
  content      = local.providers_file
  content_type = "text/plain"
  metadata     = {
    md5 = md5(local.providers_file)
  }
  tags = local.environments
}

data "aws_s3_bucket_object" "modernisation-platform-providers" {
  provider = aws.modernisation-platform
  bucket   = "modernisation-platform-terraform-state"
  key      = "providers-generated.tf"
}

resource "local_file" "providers-generated" {
  filename = "providers-generated.tf"
  content  = data.aws_s3_bucket_object.modernisation-platform-providers.body
}
