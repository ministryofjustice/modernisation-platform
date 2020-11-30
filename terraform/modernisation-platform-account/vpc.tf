# Subnets
resource "aws_default_subnet" "default_aza" {
  availability_zone = "eu-west-2a"
  tags              = local.tags
}

resource "aws_default_subnet" "default_azb" {
  availability_zone = "eu-west-2b"
  tags              = local.tags
}

resource "aws_default_subnet" "default_azc" {
  availability_zone = "eu-west-2c"
  tags              = local.tags
}
