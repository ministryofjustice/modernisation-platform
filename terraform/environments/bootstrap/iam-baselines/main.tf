resource "aws_iam_user" "cicd_member_user" {

  name = "cicd-member-user"
}

resource "aws_iam_access_key" "cicd_member_user_key" {
  user = aws_iam_user.cicd_member_user.name
}

resource "aws_iam_group" "cicd_member_group" {
  name = "cicd-member-group"
}

resource "aws_iam_policy" "policy" {
  name        = "cicd-member-policy"
  description = "IAM Policy for CICD member user"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        NotAction = [
          "iam:*",
          "organizations:*",
          "account:*",
          "ec2:DeleteNetworkAcl",
          "ec2:DeleteNetworkAclEntry",
          "ec2:DeleteRoute",
          "ec2:DeleteRouteTable",
          "ec2:CreateCustomerGateway",
          "ec2:CreateTransitGatewayConnect",
          "ec2:CreateTransitGatewayConnectPeer",
          "ec2:CreateTransitGatewayRoute",
          "ec2:CreateTransitGatewayVpcAttachment",
          "ec2:CreateDefaultVpc",
          "ec2:CreateSubnet",
          "ec2:CreateDefaultSubnet",
          "ec2:CreateVpnConnection",
          "ec2:CreateNatGateway",
          "ec2:CreateVpcEndpoint",
          "ec2:DeleteVpc",
          "ec2:DeleteVpcEndpoints",
          "ec2:DeleteNetworkAcl",
          "ec2:DeleteTransitGateway",
          "ec2:DeleteTransitGatewayVpcAttachment",
          "ec2:DeleteSubnet",
          "ec2:DisassociateTransitGatewayRouteTable",
          "ec2:DisassociateSubnetCidrBlock",
          "ec2:DisassociateRouteTable",
          "ec2:DisassociateIamInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "aws_config_attach" {
  group      = aws_iam_group.cicd_member_group
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_group_membership" "cicd-member" {
  name = "cicd-member-group-membership"

  users = [
    aws_iam_user.cicd_member_user.name
  ]

  group = aws_iam_group.cicd_member_group.name
}
