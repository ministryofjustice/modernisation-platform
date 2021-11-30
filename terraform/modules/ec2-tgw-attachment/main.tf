# Data lookups


## Look up Transit Gateway Route Tables in the host account to associate with
data "aws_ec2_transit_gateway_route_table" "default" {
  provider = aws.transit-gateway-host

  filter {
    name   = "tag:Name"
    values = [var.type]
  }

  filter {
    name   = "transit-gateway-id"
    values = [var.transit_gateway_id]
  }
}

# Resource creation

## Due to propagation in AWS, a RAM share will take up to 60 seconds to appear in an account,
## so we need to wait before attaching our tenant VPCs to it
resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
}

## Attach provided subnet IDs and VPC to the provided Transit Gateway ID
resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  provider = aws.transit-gateway-tenant

  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id

  appliance_mode_support = "disable"
  dns_support            = "enable"
  ipv6_support           = "disable"

  # You can't change these with a RAM-shared Transit Gateway, but we'll
  # leave them here to be explicit.
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-attachment"
  })

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

## Associate the Transit Gateway Route Table with the VPC
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  provider = aws.transit-gateway-host

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.default.id
}

## Retag the new Transit Gateway VPC attachment in the Transit Gateway host
resource "aws_ec2_tag" "retag" {
  provider = aws.transit-gateway-host

  resource_id = aws_ec2_transit_gateway_vpc_attachment.default.id

  key   = "Name"
  value = "${var.vpc_name}-attachment"
}
