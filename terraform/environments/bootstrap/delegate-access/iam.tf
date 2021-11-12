locals {


  account_name = try(regex("^bichard*.|^remote-supervisio*.", terraform.workspace), replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), ""))


  account_data = jsondecode(file("../../../../environments/${local.account_name}.json"))

}

module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.0.0"
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name  = "ModernisationPlatformAccess"
}

module "cicd-member-user" {

  count = local.account_data.account-type == "member" ? 1 : 0

  source = "../../../modules/iam_baseline"

  providers = {
    aws = aws.workspace
  }
}

module "member-access" {
  count  = local.account_data.account-type == "member" ? 1 : 0
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access?ref=v2.0.0"
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = aws_iam_policy.member-access[0].id
  role_name  = "MemberInfrastructureAccess"
}

data "aws_iam_policy_document" "member-access" {
  statement {
    #checkov:skip=CKV_AWS_108
    #checkov:skip=CKV_AWS_111
    #checkov:skip=CKV_AWS_107
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_110
    effect = "Allow"
    actions = [ #tfsec:ignore:AWS099
      "acm-pca:*",
      "acm:*",
      "application-autoscaling:*",
      "autoscaling:*",
      "cloudfront:*",
      "cloudwatch:*",
      "dynamodb:*",
      "ebs:*",
      "ec2:*",
      "ecr-public:*",
      "ecr:*",
      "ecs:*",
      "elasticfilesystem:*",
      "elasticloadbalancing:*",
      "events:*",
      "glacier:*",
      "guardduty:get*",
      "iam:*",
      "kms:*",
      "lambda:*",
      "logs:*",
      "organizations:Describe*",
      "organizations:List*",
      "rds-db:*",
      "rds:*",
      "route53:*",
      "s3:*",
      "secretsmanager:*",
      "ses:*",
      "sns:*",
      "sqs:*",
      "ssm:*",
      "wafv2:*"
    ]
    resources = ["*"] #tfsec:ignore:AWS099 tfsec:ignore:AWS097
  }

  statement {
    effect = "Deny"
    actions = [
      "ec2:CreateVpc",
      "ec2:CreateSubnet",
      "ec2:CreateVpcPeeringConnection",
      "ec2:CreateDhcpOptions",
      "ec2:DeleteManagedPrefixList",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:ReplaceRouteTableAssociation",
      "ec2:DeleteClientVpnEndpoint",
      "ec2:CreateTransitGatewayConnect",
      "ec2:DeleteVpcEndpoints",
      "ec2:ModifyClientVpnEndpoint",
      "ec2:RejectTransitGatewayMulticastDomainAssociations",
      "ec2:AcceptTransitGatewayVpcAttachment",
      "ec2:AttachInternetGateway",
      "ec2:DeleteLocalGatewayRouteTableVpcAssociation",
      "ec2:DeleteRouteTable",
      "ec2:ModifyVpnConnectionOptions",
      "ec2:DeleteVpnGateway",
      "ec2:CreateRoute",
      "ec2:CreateInternetGateway",
      "ec2:DeleteNetworkInsightsAnalysis",
      "ec2:DeleteInternetGateway",
      "ec2:RejectTransitGatewayVpcAttachment",
      "ec2:CreateReservedInstancesListing",
      "ec2:DisassociateTransitGatewayRouteTable",
      "ec2:DeleteTransitGatewayPeeringAttachment",
      "ec2:DeregisterTransitGatewayMulticastGroupMembers",
      "ec2:CreateLocalGatewayRouteTableVpcAssociation",
      "ec2:AssociateClientVpnTargetNetwork",
      "ec2:DisassociateRouteTable",
      "ec2:ReplaceNetworkAclAssociation",
      "ec2:CreateVpcEndpointServiceConfiguration",
      "ec2:DetachVpnGateway",
      "ec2:CreateTransitGatewayRoute",
      "ec2:CreateTransitGatewayVpcAttachment",
      "ec2:CreateDefaultVpc",
      "ec2:DeleteDhcpOptions",
      "ec2:DeleteNatGateway",
      "ec2:EnableTransitGatewayRouteTablePropagation",
      "ec2:ModifyVpcEndpoint",
      "ec2:DeleteNetworkAclEntry",
      "ec2:CreateVpnConnection",
      "ec2:ModifyVpcEndpointServicePermissions",
      "ec2:DeleteTransitGatewayPrefixListReference",
      "ec2:ExportTransitGatewayRoutes",
      "ec2:CreateNatGateway",
      "ec2:AcceptTransitGatewayPeeringAttachment",
      "ec2:ModifyTrafficMirrorFilterNetworkServices",
      "ec2:ModifyVpnConnection",
      "ec2:CreateSubnetCidrReservation",
      "ec2:DeleteTransitGatewayMulticastDomain",
      "ec2:ModifySubnetAttribute",
      "ec2:RejectTransitGatewayPeeringAttachment",
      "ec2:CreateDefaultSubnet",
      "ec2:ModifyVpnTunnelCertificate",
      "ec2:DeleteNetworkInsightsPath",
      "ec2:DeleteNetworkAcl",
      "ec2:DeleteTrafficMirrorFilter",
      "ec2:AssociateDhcpOptions",
      "ec2:CreateTrafficMirrorTarget",
      "ec2:AssignIpv6Addresses",
      "ec2:CreateClientVpnRoute",
      "ec2:AttachVpnGateway",
      "ec2:CreateLocalGatewayRoute",
      "ec2:AcceptVpcEndpointConnections",
      "ec2:CancelConversionTask",
      "ec2:AssociateTransitGatewayMulticastDomain",
      "ec2:CreateVpnConnectionRoute",
      "ec2:RevokeClientVpnIngress",
      "ec2:DeleteTrafficMirrorSession",
      "ec2:DisassociateSubnetCidrBlock",
      "ec2:RegisterTransitGatewayMulticastGroupMembers",
      "ec2:ModifyVpnTunnelOptions",
      "ec2:DeleteVpcEndpointConnectionNotifications",
      "ec2:AuthorizeClientVpnIngress",
      "ec2:ImportClientVpnClientCertificateRevocationList",
      "ec2:DeleteCustomerGateway",
      "ec2:DeleteClientVpnRoute",
      "ec2:EnableVgwRoutePropagation",
      "ec2:DisableVpcClassicLink",
      "ec2:DisableVpcClassicLinkDnsSupport",
      "ec2:ModifyVpcTenancy",
      "ec2:ApplySecurityGroupsToClientVpnTargetNetwork",
      "ec2:DeleteFlowLogs",
      "ec2:DeleteSubnet",
      "ec2:ModifyVpcEndpointServiceConfiguration",
      "ec2:DetachClassicLinkVpc",
      "ec2:DeleteVpcPeeringConnection",
      "ec2:CreateTransitGatewayRouteTable",
      "ec2:AcceptVpcPeeringConnection",
      "ec2:ModifyTransitGateway",
      "ec2:CreateTransitGatewayConnectPeer",
      "ec2:DisableVgwRoutePropagation",
      "ec2:CreateTransitGateway",
      "ec2:AssociateVpcCidrBlock",
      "ec2:ReplaceRoute",
      "ec2:RejectVpcPeeringConnection",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateVpcCidrBlock",
      "ec2:CreateTransitGatewayPrefixListReference",
      "ec2:CreateCarrierGateway",
      "ec2:CreateTransitGatewayPeeringAttachment",
      "ec2:CreatePlacementGroup",
      "ec2:DeleteTransitGatewayVpcAttachment",
      "ec2:ReplaceNetworkAclEntry",
      "ec2:ModifyTransitGatewayPrefixListReference",
      "ec2:CreateTransitGatewayMulticastDomain",
      "ec2:ModifyVpcPeeringConnectionOptions",
      "ec2:CreateVpnGateway",
      "ec2:AssociateTransitGatewayRouteTable",
      "ec2:CreateTrafficMirrorFilterRule",
      "ec2:DeleteTrafficMirrorFilterRule",
      "ec2:DeleteVpnConnection",
      "ec2:RejectVpcEndpointConnections",
      "ec2:EnableVpcClassicLink",
      "ec2:DisableTransitGatewayRouteTablePropagation",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:CreateVpcEndpointConnectionNotification",
      "ec2:CreateRouteTable",
      "ec2:DetachInternetGateway",
      "ec2:CreateCustomerGateway",
      "ec2:EnableSerialConsoleAccess",
      "ec2:ModifyVpcEndpointConnectionNotification",
      "ec2:DeleteTransitGatewayRouteTable",
      "ec2:DeleteTransitGatewayRoute",
      "ec2:CreateFlowLogs",
      "ec2:DeleteLocalGatewayRoute",
      "ec2:AssociateSubnetCidrBlock",
      "ec2:DeleteVpc",
      "ec2:CreateEgressOnlyInternetGateway",
      "ec2:DeleteTransitGateway",
      "ec2:DeleteCarrierGateway",
      "ec2:CreateTrafficMirrorFilter",
      "ec2:DeprovisionByoipCidr",
      "ec2:DeleteFleets",
      "ec2:DeleteTrafficMirrorTarget",
      "ec2:DeleteVpcEndpointServiceConfigurations",
      "ec2:ReplaceTransitGatewayRoute",
      "ec2:RegisterTransitGatewayMulticastGroupSources",
      "ec2:TerminateClientVpnConnections",
      "ec2:DeregisterTransitGatewayMulticastGroupSources",
      "ec2:CreateNetworkAcl",
      "ec2:ModifyVpcAttribute",
      "ec2:DeleteTransitGatewayConnectPeer",
      "ec2:ModifyTransitGatewayVpcAttachment",
      "ec2:DeleteEgressOnlyInternetGateway",
      "ec2:DisassociateTransitGatewayMulticastDomain",
      "ec2:DisassociateClientVpnTargetNetwork",
      "ec2:DeleteRoute",
      "ec2:CreateTrafficMirrorSession",
      "ec2:CreateClientVpnEndpoint",
      "ec2:DeleteVpnConnectionRoute",
      "ec2:CreateVpcEndpoint",
      "ec2:StartVpcEndpointServicePrivateDnsVerification",
      "ec2:AcceptReservedInstancesExchangeQuote",
      "ec2:DeleteTransitGatewayConnect",
      "ec2:EnableVpcClassicLinkDnsSupport",
      "ec2:AcceptTransitGatewayMulticastDomainAssociations",
      "ec2:CreateNetworkAclEntry",
      "ec2:DeleteSubnetCidrReservation",
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:AddUserToGroup",
      "iam:AttachGroupPolicy",
      "iam:AttachUserPolicy",
      "iam:CreateAccountAlias",
      "iam:CreateGroup",
      "iam:CreateLoginProfile",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreateSAMLProvider",
      "iam:CreateUser",
      "iam:CreateVirtualMFADevice",
      "iam:DeactivateMFADevice",
      "iam:DeleteAccountAlias",
      "iam:DeleteAccountPasswordPolicy",
      "iam:DeleteGroup",
      "iam:DeleteGroupPolicy",
      "iam:DeleteLoginProfile",
      "iam:DeleteOpenIDConnectProvider",
      "iam:DeleteSAMLProvider",
      "iam:DeleteUser",
      "iam:DeleteUserPermissionsBoundary",
      "iam:DeleteUserPolicy",
      "iam:DeleteVirtualMFADevice",
      "iam:DetachGroupPolicy",
      "iam:DetachUserPolicy",
      "iam:EnableMFADevice",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:RemoveUserFromGroup",
      "iam:ResyncMFADevice",
      "iam:UpdateAccountPasswordPolicy",
      "iam:UpdateGroup",
      "iam:UpdateLoginProfile",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:UpdateSAMLProvider",
      "iam:UpdateUser"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "member-access" {
  count    = local.account_data.account-type == "member" ? 1 : 0
  provider = aws.workspace

  name        = "MemberInfrastructureAccessActions"
  description = "Restricted admin policy for member CI/CD to use"
  policy      = data.aws_iam_policy_document.member-access.json
}

# Create a parameter for the modernisation platform environment management secret ARN that can be used to gain
# access to the environments parameter when running a tf plan locally

resource "aws_ssm_parameter" "environment_management_arn" {
  provider = aws.workspace

  name  = "environment_management_arn"
  type  = "SecureString"
  value = data.aws_secretsmanager_secret.environment_management.arn

  tags = local.environments
}
