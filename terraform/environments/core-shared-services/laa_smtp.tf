locals {
  laa_is_production = false
  laa_smtp_envs = {
    dev = {
      smtp_host_domain = "laa-development.modernisation-platform.service.justice.gov.uk"
    }
  }
  laa_smtp_ami = "ami-07c2c2bf769d5174d"
  laa_smtp_az = "eu-west-2a"
  laa_smtp_instance_type = "t2.large"
}

######################################
# laa_smtp Instance
######################################

resource "aws_instance" "laa_smtp" {
  for_each = {
    for k, v in local.laa_smtp_envs : k => v
  }
  ami                         = local.laa_smtp_ami
  availability_zone           = local.laa_smtp_az
  instance_type               = local.laa_smtp_instance_type
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.laa_smtp_non_prod.id]
  subnet_id                   = module.vpc["non_live_data"].non_tgw_subnet_ids_map.data
  iam_instance_profile        = aws_iam_instance_profile.laa_smtp.id
  user_data_base64            = data.template_file.laa_smtp_userdata.rendered
  user_data_replace_on_change = true
  metadata_options {
    http_tokens = "optional"
  }

  tags = merge(
    { "instance-scheduling" = "skip-scheduling" },
    local.tags,
    { "Name" = "LAA SMTP Server" }
  )
}

data "template_file" "laa_smtp_userdata" {
  for_each = {
    for k, v in local.laa_smtp_envs : k => v
  }
  template = file("${path.module}/laa_smtp_userdata.sh")

  vars = {
    inventory_env                 = each.key
    smtp_host_domain              = each.value.smtp_host_domain
    smtp_user_name                = aws_iam_access_key.laa_smtp.id
    smtp_user_pass                = aws_iam_access_key.laa_smtp.ses_smtp_password_v4
  }
}

#################################
# laa_smtp Security Group Rules
#################################

resource "aws_security_group" "laa_smtp_non_prod" {
  name        = "laa-non-prod-smtp-security-group"
  description = "Security Group for lower environments SMTP server"
  vpc_id      = module.vpc["non_live_data"].vpc_id

  tags = merge(
    local.tags,
    { "Name" = "laa-non-prod-smtp-security-group" }
  )

}

resource "aws_vpc_security_group_egress_rule" "laa_smtp_outbound_non_prod" {
  security_group_id = aws_security_group.laa_smtp_non_prod.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "laa_smtp_vpc_non_prod" {
  security_group_id            = aws_security_group.laa_smtp_non_prod.id
  description                  = "laa_smtp access"
  cidr_ipv4                    = module.vpc["non_live_data"].vpc_cidr_block
  from_port                    = 25
  ip_protocol                  = "tcp"
  to_port                      = 25
}

resource "aws_security_group" "laa_smtp_prod" {
  count       = local.laa_is_production == true ? 1 : 0
  name        = "laa-prod-smtp-security-group"
  description = "Security Group for production SMTP server"
  vpc_id      = module.vpc["live_data"].vpc_id

  tags = merge(
    local.tags,
    { "Name" = "laa-prod-smtp-security-group" }
  )

}

resource "aws_vpc_security_group_egress_rule" "laa_smtp_outbound_prod" {
  count       = local.laa_is_production == true ? 1 : 0
  security_group_id = aws_security_group.laa_smtp_prod[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "laa_smtp_vpc_prod" {
  count       = local.laa_is_production == true ? 1 : 0
  security_group_id            = aws_security_group.laa_smtp_prod[0].id
  description                  = "laa_smtp access"
  cidr_ipv4                    = module.vpc["live_data"].vpc_cidr_block
  from_port                    = 25
  ip_protocol                  = "tcp"
  to_port                      = 25
}

################################
# laa_smtp EC2 Instance Profile 
################################

resource "aws_iam_instance_profile" "laa_smtp" {
  name = "laa-smtp-instance-profile"
  role = aws_iam_role.laa_smtp.name
  tags = merge(
    local.tags,
    {
      Name = "laa-smtp-instance-profile"
    }
  )
}

resource "aws_iam_role" "laa_smtp" {
  name = "laa-smtp-instance-role"
  tags = merge(
    local.tags,
    {
      Name = "laa-smtp-instance-role"
    }
  )
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "laa_smtp" {
  name = "laa-smtp-iam-policy"
  tags = merge(
    local.tags,
    {
      Name = "laa-smtp-iam-policy"
    }
  )
  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutRetentionPolicy",
                "logs:PutLogEvents",
                "ec2:DescribeInstances"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:laa-postfix/*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "laa_smtp" {
  role       = aws_iam_role.laa_smtp.name
  policy_arn = aws_iam_policy.laa_smtp.arn
}

resource "aws_iam_role_policy_attachment" "laa_smtp_ssm" {
  role       = aws_iam_role.laa_smtp.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#######################################
### LAA User IAM Role
#######################################

resource "aws_iam_role" "laa_user" {
  for_each = {
    for k, v in local.laa_smtp_envs : k => v
  }
  name = "laa-user-shared-role-${each.key}"
  tags = merge(
    local.tags,
    {
      Name = "laa-user-shared-role-${each.key}"
    }
  )
  path               = "/"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : "*"
            },
            "Action" : "sts:AssumeRole",
            "Condition" : {
              "ForAnyValue:StringLike" : {
                "aws:PrincipalOrgPaths" : ["${data.aws_organizations_organization.root_account.id}/*/${local.environment_management.modernisation_platform_organisation_unit_id}/*"]
              }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "laa_user" {
  name = "laa-user-iam-policy"
  tags = merge(
    local.tags,
    {
      Name = "laa-user-iam-policy"
    }
  )
  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement": [
        {
            "Sid": "SSMStartSession",
            "Effect": "Allow",
            "Action": [
              "ssm:StartSession"
            ],
            "Resources": [
              "arn:aws:ec2:*:*:instance/laa-postfix-server",
              "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession"
            ]
          },
        {
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:eu-west-2:${data.aws_caller_identity.current.account_id}:secret:laa-postfix/*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "laa_user" {
  for_each = {
    for k, v in local.laa_smtp_envs : k => v
  }
  role       = aws_iam_role.laa_user[each.key].name
  policy_arn = aws_iam_policy.laa_user.arn
}
