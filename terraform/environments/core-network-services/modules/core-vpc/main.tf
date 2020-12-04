resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = merge(
    var.tags_common,
    {
      Name = var.tags_prefix
    },
  )
}

resource "aws_subnet" "private_tgw" {
  count = length(var.private_tgw_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_tgw_cidr_blocks, count.index)
  availability_zone = element(var.subnet_azs, count.index)

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-private-tgw${count.index + 1}"
    },
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_cidr_blocks, count.index)
  availability_zone = element(var.subnet_azs, count.index)

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-private${count.index + 1}"
    },
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_cidr_blocks, count.index)
  availability_zone = element(var.subnet_azs, count.index)

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public${count.index + 1}"
    },
  )
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-IG"
    },
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-public"
    },
  )
}

resource "aws_route" "public_ig" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route_table" "private" {
  count = length(var.private_cidr_blocks)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-private${count.index + 1}"
    },
  )
}

resource "aws_route" "private_nat" {
  count = length(var.private_cidr_blocks)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
}

resource "aws_route_table" "private_tgw" {
  count = length(var.private_tgw_cidr_blocks)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-private-tgw${count.index + 1}"
    },
  )
}

resource "aws_route" "private_tgw_nat" {
  count = length(var.private_tgw_cidr_blocks)

  route_table_id         = aws_route_table.private_tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
}

resource "aws_eip" "eip" {
  count = length(var.public_cidr_blocks)

  vpc = true

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-nat-eip${count.index + 1}"
    },
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(var.public_cidr_blocks)

  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags_common,
    {
      Name = "${var.tags_prefix}-nat-gateway${count.index + 1}"
    },
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr_blocks)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr_blocks)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private_tgw" {
  count = length(var.private_tgw_cidr_blocks)

  subnet_id      = aws_subnet.private_tgw[count.index].id
  route_table_id = aws_route_table.private_tgw[count.index].id
}
