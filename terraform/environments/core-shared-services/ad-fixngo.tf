# azure.noms.root and azure.hmpp.root AD DS infra migrated from Azure FixNGo
# For more details why this is here, please see: 
# - https://github.com/ministryofjustice/modernisation-platform/issues/5970
# - https://dsdmoj.atlassian.net/wiki/x/3oCKGAE
# Managed by DSO team, slack: #ask-digital-studio-ops 

# NOTE: remember to remove ad-fixngo-ec2-access from
# terraform/environments/bootstrap/single-sign-on/policies.tf when this is no longer required
# and firewall rules from terraform/environments/core-network-services

module "ad_fixngo_ip_addresses" {
  source = "github.com/ministryofjustice/modernisation-platform-environments//terraform/modules/ip_addresses?ref=27807807552fb132593000ea0084500ac5d39376"
}

locals {

  ad_fixngo = {

    aws_key_pairs = {
      # See https://dsdmoj.atlassian.net/wiki/x/3oCKGAE
      ad-fixngo-ec2-live    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4XM7YBLA/DY3w4oMS4PEYyfYLcK2OuidwRRUKTFyS3lnzoucuPg4fuv3yMbLJxxoUT8QjfHDWUzQRsQorkj6ig8TB68rAz0/BBx3wuA76dNoDXAXSM/sOP1ZA1gXL3BR21hbe8QIvmqP881BLgKvB5WGN7iSPIepNtxea8g6/Eg91ISLnDvVKkqjej+wJbeBKcnGCdv6LJ082HZRMxIBfAuN9snoNyjymXYU/nMeXgwZhfSzLHU9KYOAzuYxOHgVz0k1NOPYCJflSqcYyqNbuvmLmUJVSb3u/8kpOwcTR9UP0awIzuH7PXZf87g1wyfesyAkNPMa4uUoEMIIah2tp+rAp9AUDnzn5MIv84lSkerqp2+0L/dLf+FCjNpIUePpmJiC8JCqD7oemwvrEuPpsvFalmRuRNlg2s+DKg7FVdhUWH7HiIKoiSB7dBtb02AjeY5Hi8c9urFBas4LmtngEbH8mf65VZTA82S2mLjOw8DdGRGPTc/o4MilYqR7cqDcNIw3+eEw1PqYkJUykJP5saKjLZuUxe6U0dog1iY9pimPdRKiYouF95tt43+b7/7zVTajq096r/BY2XkklVmbQ/a1HBO/Q/cfQWxhaaIaQwwnAwGQdMtEZsXaJ0OR650NJYeqtKh9ZKeMF/M+HLddiC7+1ncu78NFLlB98zD8cTw=="
      ad-fixngo-ec2-nonlive = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZ7Q515wcJIdw68vUuf2v0BFow0GmqFjapC7qJ+x6eiFqfP3Cq7jT/HYS51nzJgiXUUvyXPhQcKJgQ1O0VlTX/AjctUdm9YUbArI+S74BgNFLLbDd9EsMxhm6SKjYqbhrL9S4YxA6C0hgz4+NiEJk8XKEg5laHrOCt7kmtRE8FDvyzTLZLQ7HomHkd43tDLtvTKzKkeV2iOlnYG+l0XAFLC58ufOS3ujtK9jD2vZwyarfLTiyyE/gXTtFpb+ktUnwvJpgNXDdaGHVOOjAdJh7jEmqtl438aXxfDoroX7BQmn+8nrY0lkSY+eUis58exHDqWWtUsSyHqaSUeKvyJvC0dnCUQEVulsCljFVRWeof+xcCpeHGrS4tfDop5Kckoadpwa0LILiun8NeQTLTt8jnPAU3auZZTb4u+vQeWYsE0DSWMsTMEoAh+pKBSfnAFZNYgIIp0jQKJJwL8ndTC/XPm0Wu3eorwFGnMgyNVZbkOA6yjtaknUqNVDb/9MOINZYi12NJSguLJg0tN04F0W4X6nCm2v5I72Uv5BLX/c0YpgKjHMCZdSzjS+EWD2a/WRtSUqSmg/ObHimOinPGhdM3JoIlXXUTXHCLkPADLYJ+b8e2sdEqhHFuGvLgXe302ZYftTqfZANMngkrd9tTM3uIoCxRCibicB/jJJ1u8YBqJQ=="
    }

    aws_instances = {

      # NOTE: Fixed IPs for IP allow listing and to avoid AD DNS updates
      # NOTE: Naming convention (for tags.Name and EC2 hostname)
      # ad           = active directory
      # azure/hmpp   = netbios domain name
      # dc           = domain controller
      # rdlic        = remote desktop licensing server
      # a/b/c suffix = availability zone

      ad-hmpp-dc-a = {
        ami_name                  = "hmpps_windows_server_2022_release_2024-02-02T00-00-04.569Z"
        availability_zone         = "eu-west-2a"
        iam_instance_profile_role = "ad-fixngo-ec2-live-role"
        instance_type             = "t3.large"
        key_name                  = "ad-fixngo-ec2-live"
        private_ip                = module.ad_fixngo_ip_addresses.mp_ip["ad-hmpp-dc-a"]
        subnet_id                 = aws_subnet.live-data-additional["eu-west-2a"].id
        vpc_security_group_name   = "ad_hmpp_dc_sg"
        tags = {
          server-type   = "DomainController"
          domain-name   = "azure.hmpp.root"
          description   = "domain controller for FixNGo azure.hmpp.root domain"
          os-type       = "Windows"
          patch-manager = "second-thurs"
        }
      }
      ad-hmpp-dc-b = {
        ami_name                  = "hmpps_windows_server_2022_release_2024-02-02T00-00-04.569Z"
        availability_zone         = "eu-west-2b"
        iam_instance_profile_role = "ad-fixngo-ec2-live-role"
        instance_type             = "t3.large"
        key_name                  = "ad-fixngo-ec2-live"
        private_ip                = module.ad_fixngo_ip_addresses.mp_ip["ad-hmpp-dc-b"]
        subnet_id                 = aws_subnet.live-data-additional["eu-west-2b"].id
        vpc_security_group_name   = "ad_hmpp_dc_sg"
        tags = {
          server-type   = "DomainController"
          domain-name   = "azure.hmpp.root"
          description   = "domain controller for FixNGo azure.hmpp.root domain"
          os-type       = "Windows"
          patch-manager = "forth-thurs"
        }
      }
      ad-hmpp-rdlic = {
        ami_name                  = "hmpps_windows_server_2022_release_2024-08-02T00-00-40.717Z"
        availability_zone         = "eu-west-2c"
        iam_instance_profile_role = "ad-fixngo-ec2-live-role"
        instance_type             = "t3.medium"
        key_name                  = "ad-fixngo-ec2-live"
        private_ip                = module.ad_fixngo_ip_addresses.mp_ip["ad-hmpp-rdlic"]
        subnet_id                 = aws_subnet.live-data-additional["eu-west-2c"].id
        vpc_security_group_name   = "ad_hmpp_rdlic_sg"
        tags = {
          server-type   = "RDLicensing"
          domain-name   = "azure.hmpp.root"
          description   = "remote desktop licensing server for FixNGo azure.hmpp.root domain"
          os-type       = "Windows"
          patch-manager = "forth-thurs"
        }
      }

      ad-azure-dc-a = {
        ami_name                  = "hmpps_windows_server_2022_release_2024-02-02T00-00-04.569Z"
        availability_zone         = "eu-west-2a"
        iam_instance_profile_role = "ad-fixngo-ec2-nonlive-role"
        instance_type             = "t3.large"
        key_name                  = "ad-fixngo-ec2-nonlive"
        private_ip                = module.ad_fixngo_ip_addresses.mp_ip["ad-azure-dc-a"]
        subnet_id                 = module.vpc["non_live_data"].non_tgw_subnet_ids_map.private[0]
        vpc_security_group_name   = "ad_azure_dc_sg"
        tags = {
          server-type   = "DomainController"
          domain-name   = "azure.noms.root"
          description   = "domain controller for FixNGo azure.noms.root domain"
          os-type       = "Windows"
          patch-manager = "second-thurs"
        }
      }
      ad-azure-dc-b = {
        ami_name                  = "hmpps_windows_server_2022_release_2024-02-02T00-00-04.569Z"
        availability_zone         = "eu-west-2b"
        iam_instance_profile_role = "ad-fixngo-ec2-nonlive-role"
        instance_type             = "t3.large"
        key_name                  = "ad-fixngo-ec2-nonlive"
        private_ip                = module.ad_fixngo_ip_addresses.mp_ip["ad-azure-dc-b"]
        subnet_id                 = module.vpc["non_live_data"].non_tgw_subnet_ids_map.private[1]
        vpc_security_group_name   = "ad_azure_dc_sg"
        tags = {
          server-type   = "DomainController"
          domain-name   = "azure.noms.root"
          description   = "domain controller for FixNGo azure.noms.root domain"
          os-type       = "Windows"
          patch-manager = "forth-thurs"
        }
      }
      ad-azure-rdlic = {
        ami_name                  = "hmpps_windows_server_2022_release_2024-08-02T00-00-40.717Z"
        availability_zone         = "eu-west-2c"
        iam_instance_profile_role = "ad-fixngo-ec2-nonlive-role"
        instance_type             = "t3.medium"
        key_name                  = "ad-fixngo-ec2-nonlive"
        private_ip                = module.ad_fixngo_ip_addresses.mp_ip["ad-azure-rdlic"]
        subnet_id                 = module.vpc["non_live_data"].non_tgw_subnet_ids_map.private[2]
        vpc_security_group_name   = "ad_azure_rdlic_sg"
        tags = {
          server-type   = "RDLicensing"
          domain-name   = "azure.noms.root"
          description   = "remote desktop licensing server for FixNGo azure.noms.root domain"
          os-type       = "Windows"
          patch-manager = "second-thurs"
        }
      }
    }

    cloudwatch_log_groups = {
      cwagent-windows-system = {
        retention_in_days = 400
      }
      cwagent-windows-application = {
        retention_in_days = 400
      }
      cwagent-windows-security = {
        retention_in_days = 400
      }
    }

    ec2_iam_roles = {
      # NOTE: roles will be granted access to relevant domain secrets in hmpps-domain-services accounts
      ad-fixngo-ec2-nonlive-role = {
        description = "AD FixNGo EC2 instance role for SSM, VSS snapshots and accessing non-live Secrets"
        assume_role_policy = jsonencode({
          "Version" : "2012-10-17",
          "Statement" : [{
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "ec2.amazonaws.com"
            }
            "Action" : "sts:AssumeRole",
            "Condition" : {}
          }]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
          "arn:aws:iam::aws:policy/AWSEC2VssSnapshotPolicy",
          "ad-fixngo-ec2-policy",
          "ad-fixngo-nonlive-secrets-policy",
        ]
      }
      ad-fixngo-ec2-live-role = {
        description = "AD FixNGo EC2 instance role for SSM, VSS snapshots and accessing live Secrets"
        assume_role_policy = jsonencode({
          "Version" : "2012-10-17",
          "Statement" : [{
            "Effect" : "Allow",
            "Principal" : {
              "Service" : "ec2.amazonaws.com"
            }
            "Action" : "sts:AssumeRole",
            "Condition" : {}
          }]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
          "arn:aws:iam::aws:policy/AWSEC2VssSnapshotPolicy",
          "ad-fixngo-ec2-policy",
          "ad-fixngo-live-secrets-policy",
        ]
      }
      ad-fixngo-ec2-access = {
        description = "AD FixNGo role for FleetManager EC2 console access"
        assume_role_policy = jsonencode({
          "Version" : "2012-10-17",
          "Statement" : [{
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
          }]
        })
        managed_policy_arns = [
          "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
          "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
          "ad-fixngo-fleetmanager-access-policy",
        ]
      }
    }
    ec2_iam_policies = {
      ad-fixngo-ec2-policy = {
        description = "Policy used by AD FixNGo EC2 instance roles"
        path        = "/"
        statements = [
          {
            sid    = "BusinessUnitKmsCmk"
            effect = "Allow"
            actions = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey",
              "kms:CreateGrant",
              "kms:ListGrants",
              "kms:RevokeGrant"
            ]
            resources = [
              module.kms["hmpps"].key_arns["ebs"],
              module.kms["hmpps"].key_arns["general"],
            ]
          },
          {
            sid    = "Ec2SelfProvision"
            effect = "Allow"
            actions = [
              "ec2:DescribeVolumes",
              "ec2:DescribeTags",
              "ec2:DescribeInstances"
            ]
            resources = ["*"]
          }
        ]
      }
      ad-fixngo-nonlive-secrets-policy = {
        description = "Policy used by AD FixNGo EC2 instance roles to access azure.noms.root secrets"
        path        = "/"
        statements = [
          {
            sid    = "HmppsDomainSecretsDevTest"
            effect = "Allow"
            actions = [
              "secretsmanager:GetSecretValue",
            ]
            resources = [
              "arn:aws:secretsmanager:*:${local.environment_management.account_ids.hmpps-domain-services-test}:secret:/microsoft/AD/*/shared-*",
            ]
          },
        ]
      }
      ad-fixngo-live-secrets-policy = {
        description = "Policy used by AD FixNGo EC2 instance roles to access azure.hmpp.root secrets"
        path        = "/"
        statements = [
          {
            sid    = "HmppsDomainSecretsProd"
            effect = "Allow"
            actions = [
              "secretsmanager:GetSecretValue",
            ]
            resources = [
              "arn:aws:secretsmanager:*:${local.environment_management.account_ids.hmpps-domain-services-production}:secret:/microsoft/AD/*/shared-*",
            ]
          },
        ]
      }
      ad-fixngo-fleetmanager-access-policy = {
        description = "Policy to allow FleetManager access via console",
        path        = "/",
        statements = [
          {
            sid    = "EC2",
            effect = "Allow",
            actions = [
              "ec2:GetPasswordData",
              "ec2:StartInstances",
              "ec2:StopInstances"
            ],
            resources = ["*"]
          },
          {
            sid    = "SSMStartSession",
            effect = "Allow",
            actions = [
              "ssm:StartSession",
              "ssm:DescribeInstanceInformation",
              "ssm:GetConnectionStatus",
              "ssm:DescribeSessions",
              "ssm:TerminateSession"
            ],
            resources = [
              "arn:aws:ec2:*:*:instance/*",
              "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSession",
              "arn:aws:ssm:*:*:document/SSM-SessionManagerRunShell"
            ]
          },
          {
            sid    = "SSMPermissions",
            effect = "Allow",
            actions = [
              "ssm:ListCommands",
              "ssm:ListCommandInvocations",
              "ssm:GetCommandInvocation",
              "ssm:DescribeInstanceInformation",
              "ssm:SendCommand"
            ],
            resources = ["*"]
          },
          {
            sid    = "GuiConnect",
            effect = "Allow",
            actions = [
              "ssm-guiconnect:CancelConnection",
              "ssm-guiconnect:GetConnection",
              "ssm-guiconnect:StartConnection"
            ],
            resources = ["*"]
          },
          {
            sid    = "ComputeOptimizer",
            effect = "Allow",
            actions = [
              "compute-optimizer:GetEnrollmentStatus",
              "compute-optimizer:GetEC2InstanceRecommendations"
            ],
            resources = ["*"]
          },
          {
            sid    = "KMSPermissions",
            effect = "Allow",
            actions = [
              "kms:CreateGrant",
              "kms:Decrypt",
              "kms:GenerateDataKeyWithoutPlainText",
              "kms:DescribeKey",
              "kms:ReEncrypt*"
            ],
            resources = ["*"]
          }
        ]
      }

    }

    fsx_windows_file_systems = {
      ad-azure-fsx = {
        ad_dns_ips = flatten([
          module.ad_fixngo_ip_addresses.mp_ips.ad_fixngo_azure_domain_controllers,
        ])
        ad_domain_name                      = "azure.noms.root"
        ad_file_system_administrators_group = null
        ad_username                         = "svc_join_domain"
        aliases                             = ["fs.azure.noms.root"]
        deployment_type                     = "SINGLE_AZ_1"
        security_group_name                 = "ad_azure_fsx_sg"
        storage_capacity                    = 100
        subnet_ids                          = [module.vpc["non_live_data"].non_tgw_subnet_ids_map.private[0]]
        throughput_capacity                 = 32
        weekly_maintenance_start_time       = "2:04:00" # tue 4am
      }
      ad-hmpp-fsx = {
        ad_dns_ips = flatten([
          module.ad_fixngo_ip_addresses.mp_ips.ad_fixngo_hmpp_domain_controllers,
        ])
        ad_domain_name                      = "azure.hmpp.root"
        ad_file_system_administrators_group = "AWS FSx Admins"
        ad_username                         = "svc_fsx_windows"
        aliases                             = ["fs.azure.hmpp.root", "fsprisonretail.azure.hmpp.root", "fsbranstonstaff.azure.hmpp.root", "fslinux.azure.hmpp.root"]
        deployment_type                     = "MULTI_AZ_1"
        security_group_name                 = "ad_hmpp_fsx_sg"
        storage_capacity                    = 100
        subnet_ids = [
          module.vpc["live_data"].non_tgw_subnet_ids_map.private[0],
          module.vpc["live_data"].non_tgw_subnet_ids_map.private[1],
        ]
        throughput_capacity           = 32
        weekly_maintenance_start_time = "4:04:00" # thu 4am
      }
    }

    route53_resolver_endpoints = {
      ad-fixngo-live-data = {
        direction           = "OUTBOUND"
        security_group_name = "ad_hmpp_route53_resolver_sg"
        subnet_ids          = module.vpc["live_data"].non_tgw_subnet_ids_map.private
      }
      ad-fixngo-non-live-data = {
        direction           = "OUTBOUND"
        security_group_name = "ad_azure_route53_resolver_sg"
        subnet_ids          = module.vpc["non_live_data"].non_tgw_subnet_ids_map.private
      }
    }

    route53_resolver_rules = {
      ad-fixngo-azure-noms-root = {
        domain_name = "azure.noms.root"
        target_ips = flatten([
          module.ad_fixngo_ip_addresses.azure_fixngo_ips.devtest.domain_controllers,
          module.ad_fixngo_ip_addresses.mp_ips.ad_fixngo_azure_domain_controllers,
        ])
        resolver_endpoint_name = "ad-fixngo-non-live-data"
        rule_type              = "FORWARD"
        vpc_id                 = module.vpc["non_live_data"].vpc_id
      }
      ad-fixngo-azure-hmpp-root = {
        domain_name = "azure.hmpp.root"
        target_ips = flatten([
          module.ad_fixngo_ip_addresses.azure_fixngo_ips.prod.domain_controllers,
          module.ad_fixngo_ip_addresses.mp_ips.ad_fixngo_hmpp_domain_controllers,
        ])
        resolver_endpoint_name = "ad-fixngo-live-data"
        rule_type              = "FORWARD"
        vpc_id                 = module.vpc["live_data"].vpc_id
      }
      # resolve infra.int hosts via HMPP DCs as they have forest trust
      ad-fixngo-infra-int = {
        domain_name = "infra.int"
        target_ips = flatten([
          module.ad_fixngo_ip_addresses.azure_fixngo_ips.prod.domain_controllers,
          module.ad_fixngo_ip_addresses.mp_ips.ad_fixngo_hmpp_domain_controllers,
        ])
        resolver_endpoint_name = "ad-fixngo-live-data"
        rule_type              = "FORWARD"
        vpc_id                 = module.vpc["live_data"].vpc_id
      }
    }

    security_groups = {
      ad_hmpp_route53_resolver_sg = {
        description = "Security group for azure.hmpp.root Route53 Resolver"
        vpc_id      = module.vpc["live_data"].vpc_id
        ingress     = {}
        egress = {
          dns-tcp = {
            port        = 53
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          dns-udp = {
            port        = 53
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
      }
      ad_hmpp_dc_sg = {
        description = "Security group for azure.hmpp.root DCs"
        vpc_id      = module.vpc["live_data"].vpc_id
        ingress = {
          all-from-self = {
            port     = 0
            protocol = -1
            self     = true
          }
          dns-udp-53 = {
            port        = 53
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          dns-tcp-53 = {
            port        = 53
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-udp-88 = {
            port        = 88
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-tcp-88 = {
            port        = 88
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ntp-udp-123 = {
            port        = 123
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          rpc-tcp-135 = {
            port        = 135
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          netbios-tcp-137-139 = {
            from_port   = 137
            to_port     = 139
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldap-udp-389 = {
            port        = 389
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldap-tcp-389 = {
            port        = 389
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          smb-tcp-445 = {
            port        = 445
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-udp-464 = {
            port        = 464
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-tcp-464 = {
            port        = 464
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldaps-tcp-636 = {
            port        = 636
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldap-global-catalog-tcp-3268 = {
            from_port   = 3268
            to_port     = 3269
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldaps-tcp-3269 = {
            port        = 3269
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          rdp-tcp-3389 = {
            port     = 3389
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
          winrm-tcp-5985-5986 = {
            from_port = 5985
            to_port   = 5986
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
          adws-tcp-9389 = {
            port        = 9389
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          rpc-tcp-dynamic2 = {
            from_port   = 49152
            to_port     = 65535
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
        egress = {
          all = {
            port        = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }
      ad_hmpp_fsx_sg = {
        description = "Security group for azure.hmpp.root FSX"
        vpc_id      = module.vpc["live_data"].vpc_id
        ingress = {
          smb-tcp-445 = {
            port        = 445
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          winrm-tcp-5985-5986 = {
            from_port = 5985
            to_port   = 5986
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.prod,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
        }
        egress = {
          all = {
            port        = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }
      ad_hmpp_rdlic_sg = {
        # requires RPC
        description = "security group for azure.hmpp.root remote desktop licensing server"
        vpc_id      = module.vpc["live_data"].vpc_id
        ingress = {
          all-from-self = {
            port     = 0
            protocol = -1
            self     = true
          }
          rpc-tcp-135 = {
            port     = 135
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.prod,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
          netbios-tcp-139 = {
            port     = 139
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.prod_domain_controllers,
              module.ad_fixngo_ip_addresses.mp_cidrs.ad_fixngo_hmpp_domain_controllers,
            ])
          }
          netbios-tcp-445 = {
            port     = 445
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.prod_domain_controllers,
              module.ad_fixngo_ip_addresses.mp_cidrs.ad_fixngo_hmpp_domain_controllers,
            ])
          }
          rdp-tcp-3389 = {
            port     = 3389
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
          winrm-tcp-5985-5986 = {
            from_port = 5985
            to_port   = 5986
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
          rpc-tcp-dynamic2 = {
            from_port = 49152
            to_port   = 65535
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.prod,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-preproduction,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-production,
            ])
          }
        }
        egress = {
          all = {
            port        = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }

      ad_azure_route53_resolver_sg = {
        description = "Security group for azure.noms.root Route53 Resolver"
        vpc_id      = module.vpc["non_live_data"].vpc_id
        ingress     = {}
        egress = {
          dns-tcp = {
            port        = 53
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          dns-udp = {
            port        = 53
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
      }
      ad_azure_dc_sg = {
        description = "Security group for azure.noms.root DCs"
        vpc_id      = module.vpc["non_live_data"].vpc_id
        ingress = {
          all-from-self = {
            port     = 0
            protocol = -1
            self     = true
          }
          dns-udp-53 = {
            port        = 53
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          dns-tcp-53 = {
            port        = 53
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-udp-88 = {
            port        = 88
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-tcp-88 = {
            port        = 88
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ntp-udp-123 = {
            port        = 123
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          rpc-tcp-135 = {
            port        = 135
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          netbios-tcp-139 = {
            port        = 139
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldap-udp-389 = {
            port        = 389
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldap-tcp-389 = {
            port        = 389
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          smb-tcp-445 = {
            port        = 445
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-udp-464 = {
            port        = 464
            protocol    = "UDP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          kerberos-tcp-464 = {
            port        = 464
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldaps-tcp-636 = {
            port        = 636
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldap-global-catalog-tcp-3268 = {
            from_port   = 3268
            to_port     = 3269
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          ldaps-tcp-3269 = {
            port        = 3269
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          rdp-tcp-3389 = {
            port     = 3389
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
          winrm-tcp-5985-5986 = {
            from_port = 5985
            to_port   = 5986
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
          adws-tcp-9389 = {
            port        = 9389
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          rpc-tcp-dynamic2 = {
            from_port   = 49152
            to_port     = 65535
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
        egress = {
          all = {
            port        = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }
      ad_azure_fsx_sg = {
        description = "Security group for azure.noms.root FSX"
        vpc_id      = module.vpc["non_live_data"].vpc_id
        ingress = {
          smb-tcp-445 = {
            port        = 445
            protocol    = "TCP"
            cidr_blocks = ["10.0.0.0/8"]
          }
          winrm-tcp-5985-5986 = {
            from_port = 5985
            to_port   = 5986
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
        }
        egress = {
          all = {
            port        = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }
      ad_azure_rdlic_sg = {
        description = "security group for azure.noms.root remote desktop licensing server"
        vpc_id      = module.vpc["non_live_data"].vpc_id
        ingress = {
          all-from-self = {
            port     = 0
            protocol = -1
            self     = true
          }
          rpc-tcp-135 = {
            port     = 135
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.devtest,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
          netbios-tcp-139 = {
            port     = 139
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.devtest_domain_controllers,
              module.ad_fixngo_ip_addresses.mp_cidrs.ad_fixngo_azure_domain_controllers,
            ])
          }
          netbios-tcp-445 = {
            port     = 445
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.devtest_domain_controllers,
              module.ad_fixngo_ip_addresses.mp_cidrs.ad_fixngo_azure_domain_controllers,
            ])
          }
          rdp-tcp-3389 = {
            port     = 3389
            protocol = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
          winrm-tcp-5985-5986 = {
            from_port = 5985
            to_port   = 5986
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
          rpc-tcp-dynamic2 = {
            from_port = 49152
            to_port   = 65535
            protocol  = "TCP"
            cidr_blocks = flatten([
              module.ad_fixngo_ip_addresses.azure_fixngo_cidrs.devtest,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-development,
              module.ad_fixngo_ip_addresses.mp_cidr.hmpps-test,
            ])
          }
        }
        egress = {
          all = {
            port        = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
          }
        }
      }
    }

    secretsmanager_secrets = {
      "/ad-fixngo/azure.noms.root/passwords" = {
        description = "Passwords for azure.noms.root domain"
      }
      "/ad-fixngo/azure.hmpp.root/passwords" = {
        description = "Passwords for azure.hmpp.root domain"
      }
    }

    ssm_parameters = {
      "/ad-fixngo/account_ids" = {
        description = "Account IDs used when provisioning the AD FixNGo EC2s"
        value = jsonencode({
          for key, value in local.environment_management.account_ids :
          key => value if contains(["hmpps-domain-services-test", "hmpps-domain-services-production"], key)
        })
      }
    }

    ssm_patching = {
      patch_schedules = {
        second-thurs = "cron(0 21 ? * THU#2 *)"
        forth-thurs  = "cron(0 21 ? * THU#4 *)"
      }
      patch_classifications = {
        WINDOWS = ["SecurityUpdates", "CriticalUpdates"]
      }
    }

    tags = merge(local.tags, {
      environment-name       = terraform.workspace
      infrastructure-support = "DSO:digital-studio-operations-team@digital.justice.gov.uk"
      source-code            = "https://github.com/ministryofjustice/modernisation-platform"
    })
  }

  # jiggery-pokery to get map of all policy attachments from ec2_iam_roles
  # since managed_policy_arns argument is now deprecated
  ad_fixngo_ec2_iam_roles_policy_attachment_list = flatten([
    for role_key, role_value in local.ad_fixngo.ec2_iam_roles : [
      for policy_arn in role_value.managed_policy_arns : [{
        key = "${role_key}-${policy_arn}"
        value = {
          iam_role_name = role_key
          key_or_arn    = policy_arn
        }
      }]
    ]
  ])
  ad_fixngo_ec2_iam_roles_policy_attachments = {
    for item in local.ad_fixngo_ec2_iam_roles_policy_attachment_list : item.key => item.value
  }

  ad_fixngo_secret_strings = {
    for key, value in data.aws_secretsmanager_secret_version.ad_fixngo : key => value.secret_string
  }
  ad_fixngo_secret_json = {
    for key, value in local.ad_fixngo_secret_strings : key => jsondecode(value)
  }
}

data "aws_ami" "ad_fixngo" {
  for_each = toset(distinct([for key, value in local.ad_fixngo.aws_instances : value.ami_name]))

  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [each.value]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_iam_policy_document" "ad_fixngo" {
  for_each = local.ad_fixngo.ec2_iam_policies

  dynamic "statement" {
    for_each = each.value.statements

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

data "aws_secretsmanager_secret_version" "ad_fixngo" {
  for_each = local.ad_fixngo.secretsmanager_secrets

  secret_id = aws_secretsmanager_secret.ad_fixngo[each.key].id
}

resource "aws_iam_policy" "ad_fixngo" {
  for_each = local.ad_fixngo.ec2_iam_policies

  name        = each.key
  path        = each.value.path
  description = each.value.description
  policy      = data.aws_iam_policy_document.ad_fixngo[each.key].json

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}


resource "aws_iam_role" "ad_fixngo" {
  # checkov:skip=CKV_AWS_60: "assume_role_policy is secured with the condition"
  for_each = local.ad_fixngo.ec2_iam_roles

  name                 = each.key
  description          = each.value.description
  path                 = "/"
  max_session_duration = "3600"
  assume_role_policy   = each.value.assume_role_policy

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

resource "aws_iam_role_policy_attachment" "ad_fixngo" {
  for_each = local.ad_fixngo_ec2_iam_roles_policy_attachments

  role       = aws_iam_role.ad_fixngo[each.value.iam_role_name].name
  policy_arn = try(aws_iam_policy.ad_fixngo[each.value.key_or_arn].arn, each.value.key_or_arn)
}

resource "aws_iam_instance_profile" "ad_fixngo" {
  for_each = local.ad_fixngo.aws_instances

  name = "ec2-profile-${each.key}"
  role = each.value.iam_instance_profile_role
  path = "/"

  tags = merge(local.ad_fixngo.tags, {
    Name = "ec2-profile-${each.key}"
  })
}

resource "aws_instance" "ad_fixngo" {
  for_each = local.ad_fixngo.aws_instances

  ami                    = data.aws_ami.ad_fixngo[each.value.ami_name].id
  availability_zone      = each.value.availability_zone
  ebs_optimized          = true
  iam_instance_profile   = aws_iam_instance_profile.ad_fixngo[each.key].name
  instance_type          = each.value.instance_type
  key_name               = aws_key_pair.ad_fixngo[each.value.key_name].key_name
  private_ip             = each.value.private_ip
  subnet_id              = each.value.subnet_id
  user_data_base64       = base64encode(file("./files/ad-fixngo-ec2-user-data.yaml"))
  vpc_security_group_ids = [aws_security_group.ad_fixngo[each.value.vpc_security_group_name].id]

  # remove all ephemeral block devices
  dynamic "ephemeral_block_device" {
    for_each = {
      for key, value in data.aws_ami.ad_fixngo[each.value.ami_name].block_device_mappings :
      key.device_name => value if key.device_name != data.aws_ami.ad_fixngo[each.value.ami_name].root_device_name
    }
    content {
      device_name = ephemeral_block_device.value.device_name
      no_device   = true
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = module.kms["hmpps"].key_arns["ebs"] # need to specify arn rather than id
    volume_size = 127
    volume_type = "gp3"

    tags = merge(local.ad_fixngo.tags, each.value.tags, {
      backup = "false" # exclude the ebs volume from backup as it gets backed up as part of the EC2 anyway
      Name   = join("-", [each.key, "root", data.aws_ami.ad_fixngo[each.value.ami_name].root_device_name])
    })
  }

  lifecycle {
    ignore_changes = [
      user_data,        # Prevent changes to user_data from destroying existing EC2s
      ebs_block_device, # Otherwise EC2 will be refreshed each time
    ]
  }

  tags = merge(local.ad_fixngo.tags, each.value.tags, {
    Name = each.key
  })
}

resource "aws_fsx_windows_file_system" "ad_fixngo" {
  for_each = local.ad_fixngo.fsx_windows_file_systems

  aliases                         = each.value.aliases
  automatic_backup_retention_days = 0
  deployment_type                 = each.value.deployment_type
  kms_key_id                      = module.kms["hmpps"].key_arns["general"]
  preferred_subnet_id             = each.value.deployment_type == "MULTI_AZ_1" ? each.value.subnet_ids[0] : null
  security_group_ids              = [aws_security_group.ad_fixngo[each.value.security_group_name].id]
  skip_final_backup               = true
  storage_capacity                = each.value.storage_capacity
  subnet_ids                      = each.value.subnet_ids
  throughput_capacity             = each.value.throughput_capacity
  weekly_maintenance_start_time   = each.value.weekly_maintenance_start_time

  self_managed_active_directory {
    dns_ips                          = each.value.ad_dns_ips
    domain_name                      = each.value.ad_domain_name
    file_system_administrators_group = each.value.ad_file_system_administrators_group
    password                         = local.ad_fixngo_secret_json["/ad-fixngo/${each.value.ad_domain_name}/passwords"][each.value.ad_username]
    username                         = each.value.ad_username
  }
  tags = merge(local.ad_fixngo.tags, {
    Name        = each.key
    backup      = "true"
    description = "file share for ${each.value.ad_domain_name} domain"
  })
}

resource "aws_key_pair" "ad_fixngo" {
  for_each = local.ad_fixngo.aws_key_pairs

  key_name   = each.key
  public_key = each.value

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

resource "aws_route53_resolver_endpoint" "ad_fixngo" {
  for_each = local.ad_fixngo.route53_resolver_endpoints

  name      = each.key
  direction = each.value.direction

  security_group_ids = [aws_security_group.ad_fixngo[each.value.security_group_name].id]

  dynamic "ip_address" {
    for_each = each.value.subnet_ids

    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

resource "aws_route53_resolver_rule" "ad_fixngo" {
  for_each = local.ad_fixngo.route53_resolver_rules

  domain_name = each.value.domain_name
  name        = each.key
  rule_type   = each.value.rule_type

  resolver_endpoint_id = aws_route53_resolver_endpoint.ad_fixngo[each.value.resolver_endpoint_name].id

  dynamic "target_ip" {
    for_each = each.value.target_ips
    content {
      ip = target_ip.value
    }
  }

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

resource "aws_route53_resolver_rule_association" "ad_fixngo" {
  for_each = local.ad_fixngo.route53_resolver_rules

  resolver_rule_id = aws_route53_resolver_rule.ad_fixngo[each.key].id
  vpc_id           = each.value.vpc_id
}

resource "aws_security_group" "ad_fixngo" {
  for_each = local.ad_fixngo.security_groups

  #checkov:skip=CKV2_AWS_5:skip "Ensure that Security Groups are attached to another resource" since they are attached elsewhere

  name        = each.key
  description = each.value.description
  vpc_id      = each.value.vpc_id

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

locals {
  ad_fixngo_security_group_rule_list = flatten([[
    for sg_key, sg_value in local.ad_fixngo.security_groups : [
      for rule_key, rule_value in sg_value.ingress : {
        key = "${sg_key}-ingress-${rule_key}"
        value = merge(rule_value, {
          type                = "ingress"
          security_group_name = sg_key
          description         = rule_key
        })
      }
    ]], [
    for sg_key, sg_value in local.ad_fixngo.security_groups : [
      for rule_key, rule_value in sg_value.egress : {
        key = "${sg_key}-egress-${rule_key}"
        value = merge(rule_value, {
          type                = "egress"
          security_group_name = sg_key
          description         = rule_key
        })
      }
    ]
  ]])
  ad_fixngo_security_group_rules = {
    for item in local.ad_fixngo_security_group_rule_list : item.key => item.value
  }
}

#egress to internet required for https and is controlled elsewhere, e.g. NACL/firewall
#trivy:ignore:AVD-AWS-0104
resource "aws_security_group_rule" "ad_fixngo" {
  for_each = local.ad_fixngo_security_group_rules

  type              = each.value.type
  description       = each.value.description
  from_port         = try(each.value.from_port, each.value.port)
  to_port           = try(each.value.to_port, each.value.port)
  protocol          = each.value.protocol
  cidr_blocks       = try(each.value.cidr_blocks, null)
  self              = try(each.value.self, null)
  security_group_id = aws_security_group.ad_fixngo[each.value.security_group_name].id
}

resource "aws_secretsmanager_secret" "ad_fixngo" {
  #checkov:skip=CKV2_AWS_57:Ensure Secrets Manager secrets should have automatic rotation enabled; these are domain secrets, can't be rotated automatically

  for_each = local.ad_fixngo.secretsmanager_secrets

  description = each.value.description
  kms_key_id  = module.kms["hmpps"].key_arns["general"]
  name        = each.key

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

resource "aws_ssm_parameter" "ad_fixngo" {
  for_each = local.ad_fixngo.ssm_parameters

  description = each.value.description
  key_id      = module.kms["hmpps"].key_arns["general"]
  name        = each.key
  type        = "SecureString"
  value       = each.value.value

  tags = merge(local.ad_fixngo.tags, {
    Name = each.key
  })
}

#trivy:ignore:AVD-AWS-0345: Required for SSM patching module to access S3 buckets
module "ad_fixngo_ssm_patching" {
  #checkov:skip=CKV_TF_1:Module registry does not support commit hashes for versions; this is an internal module so commit hashes are not needed
  source = "github.com/ministryofjustice/modernisation-platform-terraform-ssm-patching.git?ref=v5.1.0"
  providers = {
    aws.bucket-replication = aws
  }
  daily_definition_update = true
  account_number          = local.environment_management.account_ids["core-shared-services-production"]
  application_name        = "ad-fixngo-ssm-patching"
  environment             = "production"
  approval_days = {
    production = 14
  }
  patch_schedules       = local.ad_fixngo.ssm_patching.patch_schedules
  patch_classifications = local.ad_fixngo.ssm_patching.patch_classifications
  simple_patching       = true
  tags = merge(local.tags, {
    name   = "ad-fixngo-ssm-patching"
    module = "ssm-patching-module"
  })
}

resource "aws_cloudwatch_log_group" "ad_fixngo" {
  for_each          = local.ad_fixngo.cloudwatch_log_groups

  name              = each.key
  retention_in_days = each.value.retention_in_days
  kms_key_id        = module.kms["hmpps"].key_arns["general"]

  tags = merge(local.ad_fixngo.tags, {
    name = each.key
  })
}
