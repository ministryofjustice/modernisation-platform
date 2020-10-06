locals {
  baselines = ["securityhub"]
}

# Get AWS regions for baseline services as listed above
resource "null_resource" "baselines" {
  for_each = toset(local.baselines)

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws ssm get-parameters-by-path --path /aws/service/global-infrastructure/services/${each.value}/regions --region=eu-west-2 --output json | jq --unbuffered \"[.Parameters[].Value]\" | tee ./regions/${each.value}.json"
  }
}

resource "local_file" "baselines" {
  for_each = toset(local.baselines)
  filename = "./${each.value}.tf"
  content = templatefile("./templates/${each.value}.tmpl", {
    enabled : data.aws_regions.current.names,
    service : jsondecode(file("./regions/${each.value}.json"))
  })

  depends_on = [null_resource.baselines]
}
