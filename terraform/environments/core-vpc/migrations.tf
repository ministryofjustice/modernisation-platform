# This facilitates the migration of resources from the vpc_attachment module to the vpc module (see #8874)

# Sandbox VPCs

# garden-sandbox 
moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["garden-sandbox"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_tag.retag["application"]
  to   = module.vpc["garden-sandbox"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["garden-sandbox"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["garden-sandbox"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["garden-sandbox"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["garden-sandbox"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["garden-sandbox"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["garden-sandbox"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["garden-sandbox"].time_sleep.wait_60_seconds
  to   = module.vpc["garden-sandbox"].time_sleep.wait_60_seconds
}

# house-sandbox
moved {
  from = module.vpc_attachment["house-sandbox"].time_sleep.wait_60_seconds
  to   = module.vpc["house-sandbox"].time_sleep.wait_60_seconds
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["house-sandbox"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["house-sandbox"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_tag.retag["application"]
  to   = module.vpc["house-sandbox"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["house-sandbox"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["house-sandbox"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["house-sandbox"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["house-sandbox"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["house-sandbox"].aws_ec2_transit_gateway_route_table_association.default
}

# Development VPCs resource module migration

# cica-development
moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cica-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cica-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cica-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cica-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cica-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cica-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cica-development"].time_sleep.wait_60_seconds
  to   = module.vpc["cica-development"].time_sleep.wait_60_seconds
}

# cjse-development
moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cjse-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cjse-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cjse-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cjse-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cjse-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cjse-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cjse-development"].time_sleep.wait_60_seconds
  to   = module.vpc["cjse-development"].time_sleep.wait_60_seconds
}

# hmcts-development

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmcts-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmcts-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmcts-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmcts-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmcts-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmcts-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmcts-development"].time_sleep.wait_60_seconds
  to   = module.vpc["hmcts-development"].time_sleep.wait_60_seconds
}

# hmpps-development

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmpps-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmpps-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmpps-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmpps-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmpps-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmpps-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmpps-development"].time_sleep.wait_60_seconds
  to   = module.vpc["hmpps-development"].time_sleep.wait_60_seconds
}

# hq-development

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hq-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hq-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hq-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hq-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hq-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hq-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hq-development"].time_sleep.wait_60_seconds
  to   = module.vpc["hq-development"].time_sleep.wait_60_seconds
}

# laa-development

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["laa-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["laa-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["laa-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["laa-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["laa-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["laa-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["laa-development"].time_sleep.wait_60_seconds
  to   = module.vpc["laa-development"].time_sleep.wait_60_seconds
}

# opg-development

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["opg-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["opg-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["opg-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["opg-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["opg-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["opg-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["opg-development"].time_sleep.wait_60_seconds
  to   = module.vpc["opg-development"].time_sleep.wait_60_seconds
}

# platforms-development

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["platforms-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["platforms-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["platforms-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["platforms-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["platforms-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["platforms-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["platforms-development"].time_sleep.wait_60_seconds
  to   = module.vpc["platforms-development"].time_sleep.wait_60_seconds
}

# yjb-development

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["yjb-development"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_tag.retag["application"]
  to   = module.vpc["yjb-development"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["yjb-development"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["yjb-development"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["yjb-development"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-development"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["yjb-development"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-development"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["yjb-development"].time_sleep.wait_60_seconds
  to   = module.vpc["yjb-development"].time_sleep.wait_60_seconds
}

# Test VPCs

# cica-test
moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cica-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cica-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cica-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cica-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cica-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cica-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cica-test"].time_sleep.wait_60_seconds
  to   = module.vpc["cica-test"].time_sleep.wait_60_seconds
}

# cjse-test
moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cjse-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cjse-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cjse-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cjse-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cjse-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cjse-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cjse-test"].time_sleep.wait_60_seconds
  to   = module.vpc["cjse-test"].time_sleep.wait_60_seconds
}

# hmcts-test

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmcts-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmcts-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmcts-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmcts-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmcts-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmcts-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmcts-test"].time_sleep.wait_60_seconds
  to   = module.vpc["hmcts-test"].time_sleep.wait_60_seconds
}

# hmpps-test

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmpps-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmpps-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmpps-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmpps-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmpps-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmpps-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmpps-test"].time_sleep.wait_60_seconds
  to   = module.vpc["hmpps-test"].time_sleep.wait_60_seconds
}

# hq-test

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hq-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hq-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hq-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hq-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hq-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hq-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hq-test"].time_sleep.wait_60_seconds
  to   = module.vpc["hq-test"].time_sleep.wait_60_seconds
}

# laa-test

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["laa-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["laa-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["laa-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["laa-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["laa-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["laa-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["laa-test"].time_sleep.wait_60_seconds
  to   = module.vpc["laa-test"].time_sleep.wait_60_seconds
}

# opg-test

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["opg-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["opg-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["opg-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["opg-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["opg-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["opg-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["opg-test"].time_sleep.wait_60_seconds
  to   = module.vpc["opg-test"].time_sleep.wait_60_seconds
}

# platforms-test

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["platforms-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["platforms-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["platforms-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["platforms-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["platforms-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["platforms-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["platforms-test"].time_sleep.wait_60_seconds
  to   = module.vpc["platforms-test"].time_sleep.wait_60_seconds
}

# yjb-test

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["yjb-test"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_tag.retag["application"]
  to   = module.vpc["yjb-test"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["yjb-test"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["yjb-test"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["yjb-test"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-test"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["yjb-test"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-test"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["yjb-test"].time_sleep.wait_60_seconds
  to   = module.vpc["yjb-test"].time_sleep.wait_60_seconds
}

# Preproduction VPCs 

# cica-preproduction
moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cica-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cica-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cica-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cica-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cica-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cica-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cica-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["cica-preproduction"].time_sleep.wait_60_seconds
}

# cjse-preproduction
moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cjse-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cjse-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cjse-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cjse-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cjse-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cjse-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["cjse-preproduction"].time_sleep.wait_60_seconds
}

# hmcts-preproduction

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmcts-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmcts-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmcts-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmcts-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmcts-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmcts-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["hmcts-preproduction"].time_sleep.wait_60_seconds
}

# hmpps-preproduction

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmpps-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmpps-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmpps-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmpps-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmpps-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmpps-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["hmpps-preproduction"].time_sleep.wait_60_seconds
}

# hq-preproduction

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hq-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hq-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hq-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hq-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hq-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hq-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hq-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["hq-preproduction"].time_sleep.wait_60_seconds
}

# laa-preproduction

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["laa-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["laa-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["laa-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["laa-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["laa-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["laa-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["laa-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["laa-preproduction"].time_sleep.wait_60_seconds
}

# opg-preproduction

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["opg-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["opg-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["opg-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["opg-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["opg-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["opg-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["opg-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["opg-preproduction"].time_sleep.wait_60_seconds
}

# platforms-preproduction

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["platforms-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["platforms-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["platforms-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["platforms-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["platforms-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["platforms-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["platforms-preproduction"].time_sleep.wait_60_seconds
}

# yjb-preproduction

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["yjb-preproduction"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_tag.retag["application"]
  to   = module.vpc["yjb-preproduction"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["yjb-preproduction"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["yjb-preproduction"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["yjb-preproduction"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-preproduction"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-preproduction"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["yjb-preproduction"].time_sleep.wait_60_seconds
  to   = module.vpc["yjb-preproduction"].time_sleep.wait_60_seconds
}

# Production VPCs

# cica-production
moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cica-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cica-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cica-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cica-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cica-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cica-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cica-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cica-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cica-production"].time_sleep.wait_60_seconds
  to   = module.vpc["cica-production"].time_sleep.wait_60_seconds
}

# cjse-production
moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["cjse-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["cjse-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["cjse-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["cjse-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["cjse-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["cjse-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["cjse-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["cjse-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["cjse-production"].time_sleep.wait_60_seconds
  to   = module.vpc["cjse-production"].time_sleep.wait_60_seconds
}

# hmcts-production

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmcts-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmcts-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmcts-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmcts-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmcts-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmcts-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmcts-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmcts-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmcts-production"].time_sleep.wait_60_seconds
  to   = module.vpc["hmcts-production"].time_sleep.wait_60_seconds
}

# hmpps-production

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hmpps-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hmpps-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hmpps-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hmpps-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hmpps-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hmpps-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hmpps-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hmpps-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hmpps-production"].time_sleep.wait_60_seconds
  to   = module.vpc["hmpps-production"].time_sleep.wait_60_seconds
}

# hq-production

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["hq-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["hq-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["hq-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["hq-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["hq-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["hq-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["hq-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["hq-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["hq-production"].time_sleep.wait_60_seconds
  to   = module.vpc["hq-production"].time_sleep.wait_60_seconds
}

# laa-production

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["laa-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["laa-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["laa-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["laa-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["laa-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["laa-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["laa-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["laa-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["laa-production"].time_sleep.wait_60_seconds
  to   = module.vpc["laa-production"].time_sleep.wait_60_seconds
}

# opg-production

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["opg-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["opg-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["opg-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["opg-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["opg-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["opg-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["opg-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["opg-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["opg-production"].time_sleep.wait_60_seconds
  to   = module.vpc["opg-production"].time_sleep.wait_60_seconds
}

# platforms-production

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["platforms-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["platforms-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["platforms-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["platforms-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["platforms-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["platforms-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["platforms-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["platforms-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["platforms-production"].time_sleep.wait_60_seconds
  to   = module.vpc["platforms-production"].time_sleep.wait_60_seconds
}

# yjb-production

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_tag.retag["Name"]
  to   = module.vpc["yjb-production"].aws_ec2_tag.retag["Name"]
}

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_tag.retag["application"]
  to   = module.vpc["yjb-production"].aws_ec2_tag.retag["application"]
}

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_tag.retag["business-unit"]
  to   = module.vpc["yjb-production"].aws_ec2_tag.retag["business-unit"]
}

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_tag.retag["is-production"]
  to   = module.vpc["yjb-production"].aws_ec2_tag.retag["is-production"]
}

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_tag.retag["owner"]
  to   = module.vpc["yjb-production"].aws_ec2_tag.retag["owner"]
}

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_transit_gateway_route_table_association.default
  to   = module.vpc["yjb-production"].aws_ec2_transit_gateway_route_table_association.default
}

moved {
  from = module.vpc_attachment["yjb-production"].aws_ec2_transit_gateway_vpc_attachment.default
  to   = module.vpc["yjb-production"].aws_ec2_transit_gateway_vpc_attachment.default
}

moved {
  from = module.vpc_attachment["yjb-production"].time_sleep.wait_60_seconds
  to   = module.vpc["yjb-production"].time_sleep.wait_60_seconds
}
