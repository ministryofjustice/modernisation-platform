# As of 2020-09-29, there is an open issue regarding dynamic providers (hashicorp/terraform#24476).
# Therefore, we need to generate a file that defines providers as "static" blocks.
#
# This generates a file (providers.tf) for additional providers, based on regions that are enabled in our AWS account.
#
# This file can be committed as it only holds regional aliases.
data "aws_regions" "current" {}

resource "local_file" "providers" {
  filename = "providers.tf"
  content  = templatefile("./templates/providers.tmpl", { regions : data.aws_regions.current.names })
}
