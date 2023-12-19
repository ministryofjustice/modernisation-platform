resource "aws_directory_service_directory" "mmad-non_live" {
  name     = "non-live-data.modernisation-platform.internal"
  password = aws_secretsmanager_secret_version.mmad-non_live.secret_string
  size     = "Small"

  vpc_settings {
    vpc_id     = module.vpc["non_live_data"].vpc_id
    subnet_ids = module.vpc["non_live_data"].non_tgw_subnet_ids_map["private"]
  }

  tags = merge(
    local.tags,
    { Name = "non_live_data.modernisation-platform.internal" }
  )
}

resource "aws_secretsmanager_secret" "mmad-non_live" {
  name = "MMAD-non-live-data.modernisation-platform.internal"
}

resource "aws_secretsmanager_secret_version" "mmad-non_live" {
  secret_id     = aws_secretsmanager_secret.mmad-non_live.id
  secret_string = random_password.mmad-non_live.result
}

resource "random_password" "mmad-non_live" {
  length  = 16
  numeric = false
  special = false
}