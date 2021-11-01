# lookups for routing
data "aws_vpc" "main-public" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_route_table" "main-public" {
  vpc_id = data.aws_vpc.main-public.id

  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-public"]
  }
}
