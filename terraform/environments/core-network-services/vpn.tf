resource "aws_customer_gateway" "this" {
  for_each   = local.vpn_attachments
  bgp_asn    = each.value.bgp_asn
  ip_address = each.value.customer_gateway_ip
  type       = "ipsec.1"

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
  )
}

resource "aws_vpn_connection" "this" {
  for_each                                = local.vpn_attachments
  transit_gateway_id                      = aws_ec2_transit_gateway.transit-gateway.id
  customer_gateway_id                     = aws_customer_gateway.this[each.key].id
  static_routes_only                      = try(each.value.static_routes_only, false)
  type                                    = "ipsec.1"
  tunnel1_dpd_timeout_action              = try(each.value.tunnel_dpd_timeout_action, null)
  tunnel1_dpd_timeout_seconds             = try(each.value.tunnel_dpd_timeout_seconds, "30")
  tunnel1_ike_versions                    = try(toset(each.value.tunnel1_ike_versions), null)
  tunnel1_inside_cidr                     = try(each.value.tunnel1_inside_cidr, null)
  tunnel1_phase1_dh_group_numbers         = [try(each.value.tunnel_phase1_dh_group_numbers, null)]
  tunnel1_phase1_encryption_algorithms    = [try(each.value.tunnel_phase1_encryption_algorithms, null)]
  tunnel1_phase1_integrity_algorithms     = [try(each.value.tunnel_phase1_integrity_algorithms, null)]
  tunnel1_phase1_lifetime_seconds         = try(each.value.tunnel_phase1_lifetime_seconds, null)
  tunnel1_phase2_dh_group_numbers         = [try(each.value.tunnel_phase2_dh_group_numbers, null)]
  tunnel1_phase2_encryption_algorithms    = [try(each.value.tunnel_phase2_encryption_algorithms, null)]
  tunnel1_phase2_integrity_algorithms     = [try(each.value.tunnel_phase2_integrity_algorithms, null)]
  tunnel1_phase2_lifetime_seconds         = try(each.value.tunnel_phase2_lifetime_seconds, null)
  tunnel1_startup_action                  = try(each.value.tunnel_startup_action, null)
  tunnel1_enable_tunnel_lifecycle_control = try(each.value.tunnel1_enable_tunnel_lifecycle_control, false)
  tunnel2_dpd_timeout_action              = try(each.value.tunnel_dpd_timeout_action, null)
  tunnel2_dpd_timeout_seconds             = try(each.value.tunnel_dpd_timeout_seconds, "30")
  tunnel2_ike_versions                    = try(toset(each.value.tunnel2_ike_versions), null)
  tunnel2_inside_cidr                     = try(each.value.tunnel2_inside_cidr, null)
  tunnel2_phase1_dh_group_numbers         = [try(each.value.tunnel_phase1_dh_group_numbers, null)]
  tunnel2_phase1_encryption_algorithms    = [try(each.value.tunnel_phase1_encryption_algorithms, null)]
  tunnel2_phase1_integrity_algorithms     = [try(each.value.tunnel_phase1_integrity_algorithms, null)]
  tunnel2_phase1_lifetime_seconds         = try(each.value.tunnel_phase1_lifetime_seconds, null)
  tunnel2_phase2_dh_group_numbers         = [try(each.value.tunnel_phase2_dh_group_numbers, null)]
  tunnel2_phase2_encryption_algorithms    = [try(each.value.tunnel_phase2_encryption_algorithms, null)]
  tunnel2_phase2_integrity_algorithms     = [try(each.value.tunnel_phase2_integrity_algorithms, null)]
  tunnel2_phase2_lifetime_seconds         = try(each.value.tunnel_phase2_lifetime_seconds, null)
  tunnel2_startup_action                  = try(each.value.tunnel_startup_action, null)
  tunnel2_enable_tunnel_lifecycle_control = try(each.value.tunnel2_enable_tunnel_lifecycle_control, false)
  remote_ipv4_network_cidr                = try(each.value.remote_ipv4_network_cidr, local.core-vpcs[each.value.modernisation_platform_vpc].cidr.subnet_sets["general"].cidr)

  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.vpn_attachments[each.key].arn
      log_output_format = "json"
    }
  }

  tunnel2_log_options {
    cloudwatch_log_options {
      log_enabled       = true
      log_group_arn     = aws_cloudwatch_log_group.vpn_attachments[each.key].arn
      log_output_format = "json"
    }
  }

  tags = merge(
    local.tags,
    { "Name" = replace(each.key, "_", "-") },
    try({ "github-environment" = each.value.github_environment }, {})
  )

  lifecycle {
    ignore_changes = [
      tunnel1_phase1_dh_group_numbers, tunnel1_phase1_encryption_algorithms, tunnel1_phase1_integrity_algorithms,
      tunnel1_phase2_dh_group_numbers, tunnel1_phase2_encryption_algorithms, tunnel1_phase2_integrity_algorithms,
      tunnel2_phase1_dh_group_numbers, tunnel2_phase1_encryption_algorithms, tunnel2_phase1_integrity_algorithms,
      tunnel2_phase2_dh_group_numbers, tunnel2_phase2_encryption_algorithms, tunnel2_phase2_integrity_algorithms,
    ]
  }

}

resource "aws_ec2_transit_gateway_route_table_association" "vpn_attachments" {
  for_each                       = local.vpn_attachments
  transit_gateway_attachment_id  = aws_vpn_connection.this[each.key].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_in.id
}

# To prevent BGP routes from sending traffic via VPNs, we need static routes to override them
resource "aws_ec2_transit_gateway_route" "azure_static_routes" {
  for_each                       = toset(local.azure_static_routes)
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.moj_tgw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_noms_routes_to_firewall" {
  depends_on                     = [aws_ec2_transit_gateway_route.azure_static_routes]
  for_each                       = local.noms_vpn_attachment_ids
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_nec_routes_to_firewall" {
  for_each                       = local.nec_vpn_attachment_ids
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route" "parole_board_routes" {
  for_each                       = toset(local.parole_board_vpn_static_routes)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["Parole-Board-VPN"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_ec2_transit_gateway_route" "yjb_routes_srx01" {
  for_each                       = toset(local.yjb_vpn_static_route_srx01)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["YJB-Juniper-vSRX01-VPN"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}
resource "aws_ec2_transit_gateway_route" "yjb_routes_srx02" {
  for_each                       = toset(local.yjb_vpn_static_route_srx02)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["YJB-Juniper-vSRX02-VPN"].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}

resource "aws_cloudwatch_log_group" "vpn_attachments" {
  # checkov:skip=CKV_AWS_158: "logs will not be shared so standard encryption fine"
  for_each          = local.vpn_attachments
  name              = "${replace(each.key, "_", "-")}-vpn-attachment-logs"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_dx_gateway_association_proposal" "this" {
  for_each = {
    for k, v in local.vpn_attachments : k => v
    if try((v.dx_gateway_id != ""), false)
  }
  dx_gateway_id               = try(each.value.dx_gateway_id, null)
  dx_gateway_owner_account_id = try(each.value.dx_gateway_owner_account_id, null)
  associated_gateway_id       = aws_customer_gateway.this[each.key].id
}

# VPN Health Alerts - Reusable Notification System
# This creates SNS topics and EventBridge rules for VPNs with notification settings configured
# See locals.tf for vpns_with_notifications, vpns_by_slack_channel, and vpns_by_email

# SNS Topics for VPN health alerts (one per VPN with notifications configured)
resource "aws_sns_topic" "vpn_health_alerts_slack" {
  for_each          = local.vpn_slack_notifications
  name              = "vpn-health-alerts-${replace(each.key, "_", "-")}"
  kms_master_key_id = aws_kms_key.sns_kms_key.id

  tags = merge(
    local.tags,
    {
      "Name"              = "vpn-health-alerts-${replace(each.key, "_", "-")}"
      "notification-type" = "slack"
      "slack-channel-id"  = each.value
      "vpn-name"          = each.key
    }
  )
}

resource "aws_sns_topic" "vpn_health_alerts_email" {
  for_each          = local.vpn_email_notifications
  name              = "vpn-health-alerts-${replace(each.key, "_", "-")}"
  kms_master_key_id = aws_kms_key.sns_kms_key.id

  tags = merge(
    local.tags,
    {
      "Name"               = "vpn-health-alerts-${replace(each.key, "_", "-")}"
      "notification-type"  = "email"
      "notification-email" = each.value
      "vpn-name"           = each.key
    }
  )
}

# SNS Topic Policies
resource "aws_sns_topic_policy" "vpn_health_alerts_slack" {
  for_each = aws_sns_topic.vpn_health_alerts_slack
  arn      = each.value.arn
  policy   = data.aws_iam_policy_document.vpn_health_sns_topic_policy["slack-${each.key}"].json
}

resource "aws_sns_topic_policy" "vpn_health_alerts_email" {
  for_each = aws_sns_topic.vpn_health_alerts_email
  arn      = each.value.arn
  policy   = data.aws_iam_policy_document.vpn_health_sns_topic_policy["email-${each.key}"].json
}

data "aws_iam_policy_document" "vpn_health_sns_topic_policy" {
  for_each  = local.all_vpn_health_notifications
  policy_id = "vpn health sns topic policy"

  statement {
    sid    = "Allow topic owner to manage sns topic"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:AddPermission",
      "sns:Subscribe"
    ]
    resources = [
      startswith(each.key, "slack-") ? aws_sns_topic.vpn_health_alerts_slack[replace(each.key, "slack-", "")].arn : aws_sns_topic.vpn_health_alerts_email[replace(each.key, "email-", "")].arn
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        local.environment_management.account_ids["core-network-services-production"]
      ]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid    = "Allow eventbridge to publish messages to sns topic"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      startswith(each.key, "slack-") ? aws_sns_topic.vpn_health_alerts_slack[replace(each.key, "slack-", "")].arn : aws_sns_topic.vpn_health_alerts_email[replace(each.key, "email-", "")].arn
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# Email Subscriptions
resource "aws_sns_topic_subscription" "vpn_health_email" {
  for_each  = local.vpn_email_notifications
  topic_arn = aws_sns_topic.vpn_health_alerts_email[each.key].arn
  protocol  = "email"
  endpoint  = each.value
}

# EventBridge Rules for VPN Health Events (one rule per VPN)
resource "aws_cloudwatch_event_rule" "vpn_health_slack" {
  for_each    = local.vpn_slack_notifications
  name        = "vpn-health-alerts-${replace(each.key, "_", "-")}"
  description = "Monitor VPN health events for ${each.key} notifying Slack channel ${each.value}"

  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "resources" = [
      aws_vpn_connection.this[each.key].id
    ]
  })

  tags = merge(
    local.tags,
    {
      "notification-type" = "slack"
      "slack-channel-id"  = each.value
      "vpn-name"          = each.key
    }
  )
}

resource "aws_cloudwatch_event_rule" "vpn_health_email" {
  for_each    = local.vpn_email_notifications
  name        = "vpn-health-alerts-${replace(each.key, "_", "-")}"
  description = "Monitor VPN health events for ${each.key} notifying email ${each.value}"

  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "resources" = [
      aws_vpn_connection.this[each.key].id
    ]
  })

  tags = merge(
    local.tags,
    {
      "notification-type"  = "email"
      "notification-email" = each.value
      "vpn-name"           = each.key
    }
  )
}

# EventBridge Targets
resource "aws_cloudwatch_event_target" "vpn_health_slack" {
  for_each  = local.vpn_slack_notifications
  rule      = aws_cloudwatch_event_rule.vpn_health_slack[each.key].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.vpn_health_alerts_slack[each.key].arn
}

resource "aws_cloudwatch_event_target" "vpn_health_email" {
  for_each  = local.vpn_email_notifications
  rule      = aws_cloudwatch_event_rule.vpn_health_email[each.key].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.vpn_health_alerts_email[each.key].arn
}

resource "aws_kms_key" "sns_kms_key" {
  description         = "KMS key for SNS topic encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.sns-kms.json
}

resource "aws_kms_alias" "sns_kms_alias" {
  name          = "alias/sns-kms-key"
  target_key_id = aws_kms_key.sns_kms_key.id
}

# Static code analysis ignores:
# - CKV_AWS_109 and CKV_AWS_111: Ignore warnings regarding resource = ["*"]. See https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
#   Specifically: "In a key policy, the value of the Resource element is "*", which means "this KMS key." The asterisk ("*") identifies the KMS key to which the key policy is attached."
data "aws_iam_policy_document" "sns-kms" {
  # checkov:skip=CKV_AWS_109: "Key policy requires asterisk resource - see note above"
  # checkov:skip=CKV_AWS_111: "Key policy requires asterisk resource - see note above"
  # checkov:skip=CKV_AWS_356: "Key policy requires asterisk resource - see note above"

  statement {
    sid    = "Allow management access of the key to the core-network-services account"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
  statement {
    sid     = "Allow SNS and Eventbridge services to use the key"
    effect  = "Allow"
    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# AWS Chatbot for Slack notifications (one per unique Slack channel)
module "vpn_health_chatbot" {
  source   = "github.com/ministryofjustice/modernisation-platform-terraform-aws-chatbot?ref=0ec33c7bfde5649af3c23d0834ea85c849edf3ac" # v3.0.0
  for_each = local.vpns_by_slack_channel

  slack_channel_id = each.key
  sns_topic_arns = [
    for vpn_name in each.value :
    "arn:aws:sns:eu-west-2:${local.environment_management.account_ids[terraform.workspace]}:${aws_sns_topic.vpn_health_alerts_slack[vpn_name].name}"
  ]
  tags             = local.tags
  application_name = "${local.application_name}-vpn-health-${substr(md5(each.key), 0, 8)}"
}
