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
  tunnel1_ike_versions                    = try(each.value.tunnel_ike_versions, null)
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
  tunnel2_ike_versions                    = try(each.value.tunnel2_ike_versions, null)
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
  )

  lifecycle {
    ignore_changes = [
      tunnel1_ike_versions, tunnel1_phase1_dh_group_numbers, tunnel1_phase1_encryption_algorithms, tunnel1_phase1_integrity_algorithms,
      tunnel1_phase2_dh_group_numbers, tunnel1_phase2_encryption_algorithms, tunnel1_phase2_integrity_algorithms,
      tunnel2_ike_versions, tunnel2_phase1_dh_group_numbers, tunnel2_phase1_encryption_algorithms, tunnel2_phase1_integrity_algorithms,
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

resource "aws_ec2_transit_gateway_route" "parole_board_routes" {
  for_each                       = toset(local.parole_board_vpn_static_routes)
  destination_cidr_block         = each.key
  transit_gateway_attachment_id  = aws_vpn_connection.this["Parole-Board-VPN"].transit_gateway_attachment_id
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

# Enable Slack alerting to #dba_alerts_prod channel when we receive AWS Health notifications for upcoming tunnel endpoint replacements
resource "aws_cloudwatch_event_rule" "noms-vpn-event-rule" {
  name        = "noms-vpn-health-event-rule"
  description = "Check for any NOMS VPN related health events"
  event_pattern = jsonencode({
    "source" : ["aws.health"],
    "detail-type" : ["AWS Health Event"],
    "resources" = [
      aws_vpn_connection.this["NOMS-Transit-Live-VPN-VNG_1"].id,
      aws_vpn_connection.this["NOMS-Transit-Live-VPN-VNG_2"].id
    ]
  })
}

resource "aws_cloudwatch_event_target" "noms-vpn-event-target-sns" {
  rule      = aws_cloudwatch_event_rule.noms-vpn-event-rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.noms_vpn_sns_topic.arn
}

resource "aws_sns_topic" "noms_vpn_sns_topic" {
  name              = "noms_vpn_sns_topic"
  kms_master_key_id = aws_kms_key.sns_kms_key.id
}
resource "aws_sns_topic_policy" "noms_vpn_sns_topic" {
  arn    = aws_sns_topic.noms_vpn_sns_topic.arn
  policy = data.aws_iam_policy_document.noms_vpn_sns_topic_policy.json
}

data "aws_iam_policy_document" "noms_vpn_sns_topic_policy" {
  policy_id = "nomis vpn sns topic policy"

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
      aws_sns_topic.noms_vpn_sns_topic.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        local.environment_management.account_ids["core-network-services-production"]
      ]
    }
    principals {
      type = "AWS"
      identifiers = [
        "*"
      ]
    }
  }
  statement {
    sid    = "Allow eventbridge to publish messages to sns topic"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.noms_vpn_sns_topic.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
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

module "core-networks-chatbot" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-aws-chatbot?ref=73280f80ce8a4557cec3a76ee56eb913452ca9aa" // v2.0.0

  slack_channel_id = "CDLAJTGRG" // #dba_alerts_prod
  sns_topic_arns   = ["arn:aws:sns:eu-west-2:${local.environment_management.account_ids[terraform.workspace]}:${aws_sns_topic.noms_vpn_sns_topic.name}"]
  tags             = local.tags
  application_name = local.application_name
}

resource "aws_ec2_transit_gateway_route_table_propagation" "propagate_yjb_routes_to_firewall" {
  for_each                       = local.yjb_vpn_attachment_ids
  transit_gateway_attachment_id  = each.key
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.external_inspection_out.id
}