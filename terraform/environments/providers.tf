# As of 2020-09-29, there is an open issue regarding dynamic providers (hashicorp/terraform#24476).
# Therefore, we need to generate a file that defines providers as "static" blocks.
#
# This generates a file for additional providers, based on accounts created through the "environments" module
# in environments.tf.
locals {
  providers_file = templatefile("providers.tmpl", {
    accounts : local.environment_management.account_ids
  })
}

resource "local_file" "providers-generated" {
  filename = "providers-generated.tf"
  content  = local.providers_file
}
