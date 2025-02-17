# This short-lived file should exist only until the moved blocks have been integrated into state, and then deleted.

# core-vpc-sandbox
moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["garden-sandbox"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["house-sandbox"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["garden-sandbox"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["house-sandbox"].aws_ec2_transit_gateway_route_table_association.type
}

# core-vpc-development
moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-development"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-development"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-development"].aws_ec2_transit_gateway_route_table_association.type
}

# core-vpc-test
moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-test"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-test"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-test"].aws_ec2_transit_gateway_route_table_association.type
}

# core-vpc-preproduction
moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-preproduction"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-preproduction"].aws_ec2_transit_gateway_route_table_association.type
}

# core-vpc-production
moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-production"].aws_ec2_transit_gateway_vpc_attachment.main
}
moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-production"].aws_ec2_transit_gateway_route_table_association.type
}
moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-production"].aws_ec2_transit_gateway_route_table_association.type
}