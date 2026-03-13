data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

data "aws_organizations_organization" "root_account" {}

locals {
  application_name = "core-network-services"
  # Custom VPC flow log statement
  custom_tgw_flow_log_format = "$${version} $${resource-type} $${account-id} $${tgw-id} $${tgw-attachment-id} $${tgw-src-vpc-account-id} $${tgw-dst-vpc-account-id} $${tgw-src-vpc-id} $${tgw-dst-vpc-id} $${tgw-src-subnet-id} $${tgw-dst-subnet-id} $${tgw-src-eni} $${tgw-dst-eni} $${tgw-src-az-id} $${tgw-dst-az-id} $${tgw-pair-attachment-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${log-status} $${type} $${packets-lost-no-route} $${packets-lost-blackhole} $${packets-lost-mtu-exceeded} $${packets-lost-ttl-expired} $${tcp-flags} $${region} $${flow-direction} $${pkt-src-aws-service} $${pkt-dst-aws-service}"
  custom_vpc_flow_log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"

  core_logging_bucket_arns      = jsondecode(data.aws_ssm_parameter.core_logging_bucket_arns.insecure_value)
  cloudwatch_generic_log_groups = concat([module.firewall_logging.cloudwatch_log_group_name], [for key, value in module.vpc_inspection : value.fw_cloudwatch_name])

  tags = {
    business-unit = "Platforms"
    service-area  = "Hosting"
    application   = "Modernisation Platform: core-network-services"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }

  active_tgw_peering_attachments = [
    "MOJ-TGW-attachment-accepter"
  ]

  active_tgw_vpc_attachments = [
    "hmcts-production-attachment",
    "hmpps-production-attachment",
    "core-network-services-live_data-attachment",
  ]

  sandbox_rules         = fileexists("./firewall-rules/sandbox_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/sandbox_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/sandbox_rules.json", local.all_cidr_ranges))[k] } : {}
  development_rules     = fileexists("./firewall-rules/development_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/development_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/development_rules.json", local.all_cidr_ranges))[k] } : {}
  test_rules            = fileexists("./firewall-rules/test_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/test_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/test_rules.json", local.all_cidr_ranges))[k] } : {}
  preproduction_rules   = fileexists("./firewall-rules/preproduction_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/preproduction_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/preproduction_rules.json", local.all_cidr_ranges))[k] } : {}
  production_rules      = fileexists("./firewall-rules/production_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/production_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/production_rules.json", local.all_cidr_ranges))[k] } : {}
  live_data_rules       = fileexists("./firewall-rules/live_data_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/live_data_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/live_data_rules.json", local.all_cidr_ranges))[k] } : {}
  non_live_data_rules   = fileexists("./firewall-rules/non_live_data_rules.json") ? { for k in sort(keys(jsondecode(templatefile("./firewall-rules/non_live_data_rules.json", local.all_cidr_ranges)))) : k => jsondecode(templatefile("./firewall-rules/non_live_data_rules.json", local.all_cidr_ranges))[k] } : {}
  fqdn_firewall_rules   = fileexists("./firewall-rules/fqdn_rules.json") ? jsondecode(file("./firewall-rules/fqdn_rules.json")) : {}
  inline_firewall_rules = fileexists("./firewall-rules/inline_rules.json") ? jsondecode(templatefile("./firewall-rules/inline_rules.json", local.all_cidr_ranges)) : {}


  firewall_rules = merge(
    local.sandbox_rules,
    local.development_rules,
    local.test_rules,
    local.preproduction_rules,
    local.production_rules,
    local.live_data_rules,
    local.non_live_data_rules
  )
  firewall_sets = fileexists("./firewall-rules/sets.json") ? jsondecode(templatefile("./firewall-rules/sets.json", local.all_cidr_ranges)) : {}

  vpn_attachments = fileexists("./vpn_attachments.json") ? jsondecode(file("./vpn_attachments.json")) : tomap({})

  vpn_lifecycle_control_ids = [
    for name, cfg in local.vpn_attachments :
    name
    if(
      (try(cfg.tunnel1_enable_tunnel_lifecycle_control, "false") == "true") ||
      (try(cfg.tunnel2_enable_tunnel_lifecycle_control, "false") == "true")
    )
  ]

  vpn_lifecycle_control_arns = [
    for k, v in aws_vpn_connection.this :
    v.arn
    if contains(local.vpn_lifecycle_control_ids, k)
  ]

  github_repository_environments_from_vpns = distinct([
    for vpn_id, vpn in local.vpn_attachments :
    "ministryofjustice/modernisation-platform-environments:environment:${vpn.github_environment}"
    if contains(keys(vpn), "github_environment") && vpn.github_environment != ""
  ])

  noms_vpn_attachment_ids = toset([for k in aws_vpn_connection.this : k.transit_gateway_attachment_id if(length(regexall("(?:NOMS)", k.tags.Name)) > 0)])

  nec_vpn_attachment_ids = toset([for k in aws_vpn_connection.this : k.transit_gateway_attachment_id if(length(regexall("(?:NEC)", k.tags.Name)) > 0)])

  azure_static_routes = [
    "10.0.0.0/11",
    "10.64.0.0/11",
    "10.100.0.0/15",
    "10.104.0.0/16",
    "10.108.0.0/18",
    "10.108.64.0/23",
    "10.128.0.0/16",
    "10.132.0.0/16",
    "10.136.0.0/13",
    "10.147.0.0/16",
    "10.148.0.0/14",
    "10.154.0.0/23",
    "10.154.16.0/23",
    "10.154.32.0/23",
    "10.154.48.0/23",
    "10.154.64.0/23",
    "10.154.80.0/23",
    "10.154.96.0/23",
    "10.154.112.0/23",
    "10.154.128.0/23",
    "10.154.144.0/23",
    "10.154.160.0/23",
    "10.154.176.0/23",
    "10.154.192.0/23",
    "10.154.208.0/23",
    "10.154.240.0/21",
    "10.154.224.0/21",
    "10.180.0.0/16",
    "10.184.128.0/18",
    "10.184.192.0/18",
    "10.184.32.0/19",
    "10.184.64.0/19",
    "10.184.96.0/19",
    "10.185.0.0/16",
    "10.155.0.0/23",
    "10.159.240.0/20",
    "10.163.0.0/20",
    "10.171.0.0/16",
    "10.172.0.0/16",
    "10.175.0.0/16",
    "10.176.0.0/16",
    "10.178.0.0/16",
    "10.179.0.0/16",
    "10.188.0.160/27",
    "10.205.0.0/24",
    "10.208.0.0/12",
    "10.211.0.0/22",
    "10.228.224.0/19",
    "10.231.252.0/23",
    "10.232.0.0/16",
    "10.233.64.0/18",
    "10.233.128.0/18",
    "10.233.192.0/20",
    "10.233.208.0/22",
    "10.233.212.0/23",
    "10.233.214.0/23",
    "10.233.216.0/21",
    "10.233.224.0/19",
    "10.234.0.0/15",
    "10.236.0.0/14",
    "10.240.0.0/16",
    "10.243.224.0/20",
    "10.245.252.0/22",
    "172.16.0.0/12",
    "172.16.9.0/24",
    "172.16.10.0/24",
    "172.17.0.0/16",
    "172.18.0.0/15",
    "172.20.0.0/15",
    "172.22.0.0/15",
    "172.25.181.0/24",
    "195.59.116.244/32"
  ]

  parole_board_vpn_static_routes = ["10.50.0.0/16"]

  yjb_vpn_static_route_srx01 = ["10.20.228.0/22"]

  yjb_vpn_static_route_srx02 = ["10.20.224.0/22"]


  core-vpcs = {
    for file in fileset("../../../environments-networks", "*.json") :
    replace(file, ".json", "") => jsondecode(file("../../../environments-networks/${file}"))
  }

  # VPN Health Alerts - Notification Configuration
  # Filter VPN attachments that have notification settings
  vpns_with_notifications = {
    for name, cfg in local.vpn_attachments :
    name => cfg
    if(
      try(cfg.notification_slack_channel_id, "") != "" ||
      try(cfg.notification_email, "") != ""
    )
  }

  # Create maps using VPN names as keys for Slack notifications
  vpn_slack_notifications = {
    for name, cfg in local.vpns_with_notifications :
    name => cfg.notification_slack_channel_id
    if try(cfg.notification_slack_channel_id, "") != ""
  }

  # Create maps using VPN names as keys for Email notifications
  vpn_email_notifications = {
    for name, cfg in local.vpns_with_notifications :
    name => cfg.notification_email
    if try(cfg.notification_email, "") != ""
  }

  # Group VPNs by notification destination (for EventBridge rules that can handle multiple VPNs)
  vpns_by_slack_channel = {
    for channel_id in distinct([
      for name, cfg in local.vpns_with_notifications :
      cfg.notification_slack_channel_id
      if try(cfg.notification_slack_channel_id, "") != ""
    ]) :
    channel_id => [
      for name, cfg in local.vpns_with_notifications :
      name
      if try(cfg.notification_slack_channel_id, "") == channel_id
    ]
  }

  vpns_by_email = {
    for email in distinct([
      for name, cfg in local.vpns_with_notifications :
      cfg.notification_email
      if try(cfg.notification_email, "") != ""
    ]) :
    email => [
      for name, cfg in local.vpns_with_notifications :
      name
      if try(cfg.notification_email, "") == email
    ]
  }

  # Create EventBridge rule keys using first VPN name for each destination (one rule per destination)
  vpn_eventbridge_slack_rules = {
    for channel_id, vpn_list in local.vpns_by_slack_channel :
    vpn_list[0] => {
      channel_id = channel_id
      vpn_list   = vpn_list
    }
  }

  vpn_eventbridge_email_rules = {
    for email, vpn_list in local.vpns_by_email :
    vpn_list[0] => {
      email    = email
      vpn_list = vpn_list
    }
  }

  # Combine all VPN notification configs for unified policy handling
  all_vpn_health_notifications = merge(
    { for k, v in local.vpn_slack_notifications : "slack-${k}" => v },
    { for k, v in local.vpn_email_notifications : "email-${k}" => v }
  )

}
