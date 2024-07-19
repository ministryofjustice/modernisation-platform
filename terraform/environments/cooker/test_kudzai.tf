resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ssm_vpc_endpoint_policy" {
  name = "ssm_vpc_endpoint_policy"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateVpcEndpoint",
          "ec2:DescribeVpcEndpoints",
          "ec2:DeleteVpcEndpoints"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "test_kudzai_my_sg"
  description = "Security group for my EC2 instance"
  vpc_id      = "vpc-0126ab422acc979ef"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test_kudzai_my_sg"
  }
}

# VPC Endpoints
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = "vpc-0126ab422acc979ef"
  service_name      = "com.amazonaws.eu-west-2.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["subnet-0943ad4d71c40fa21"]

  security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = "vpc-0126ab422acc979ef"
  service_name      = "com.amazonaws.eu-west-2.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["subnet-0943ad4d71c40fa21"]

  security_group_ids = [aws_security_group.my_sg.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = "vpc-0126ab422acc979ef"
  service_name      = "com.amazonaws.eu-west-2.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["subnet-0943ad4d71c40fa21"]

  security_group_ids = [aws_security_group.my_sg.id]
}

# EC2 Instance with User Data to Install SSM Agent on Red Hat
resource "aws_instance" "myec2" {
  ami                    = "ami-07d1e0a32156d0d21"  # Replace with your desired AMI ID
  instance_type          = "t2.micro"              # Replace with your desired instance type
  subnet_id              = "subnet-0943ad4d71c40fa21"  # Replace with your subnet ID
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  # key_name               = "ec2-keypair"           # Use the existing key pair name

  tags = {
    Name = "test_kudzai_instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y https://s3.amazonaws.com/amazon-ssm-eu-west-2/latest/linux_amd64/amazon-ssm-agent.rpm
    sudo systemctl enable amazon-ssm-agent
    sudo systemctl start amazon-ssm-agent
  EOF
}

# Outputs for debugging
output "ssm_role_arn" {
  value = aws_iam_role.ssm_role.arn
}

output "ssm_instance_profile_arn" {
  value = aws_iam_instance_profile.ssm_instance_profile.arn
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}

output "vpc_endpoint_ssm_id" {
  value = aws_vpc_endpoint.ssm.id
}

output "vpc_endpoint_ssmmessages_id" {
  value = aws_vpc_endpoint.ssmmessages.id
}

output "vpc_endpoint_ec2messages_id" {
  value = aws_vpc_endpoint.ec2messages.id
}

output "ec2_instance_id" {
  value = aws_instance.myec2.id
}






# locals {
#   instance_config = {
#     associate_public_ip_address  = false
#     disable_api_termination      = false
#     disable_api_stop             = false
#     instance_type                = var.ec2_instance_type
#     key_name                     = var.ec2_key_pair_name
#     metadata_endpoint_enabled    = var.metadata_options.http_endpoint
#     metadata_options_http_tokens = var.metadata_options.http_tokens
#     monitoring                   = var.monitoring
#     ebs_block_device_inline      = true
#     vpc_security_group_ids       = var.security_group_ids
#     private_dns_name_options = {
#       enable_resource_name_dns_aaaa_record = false
#       enable_resource_name_dns_a_record    = true
#       hostname_type                        = "resource-name"
#     }
#     tags = var.tags
#   }

# }

# module "instance" {
#   source = "github.com/ministryofjustice/modernisation-platform-terraform-ec2-instance"

#   providers = {
#     aws.core-vpc = aws.core-vpc # core-vpc-(environment) holds the networking for all accounts
#   }

#   name = "${var.account_info.application_name}-${var.env_name}-${var.db_suffix}-${local.instance_name_index}" # e.g. dev-boe-db-1

#   ami_name                      = data.aws_ami.oracle_db.name
#   ami_owner                     = var.db_ami.owner
#   instance                      = local.instance_config
#   ebs_kms_key_id                = var.account_config.kms_keys.general_shared
#   ebs_volumes_copy_all_from_ami = true
#   ebs_volume_config             = var.ebs_volume_config
#   ebs_volumes                   = var.ebs_volumes
#   ebs_volume_tags               = var.tags
#   # route53_records               = merge(local.ec2_test.route53_records, lookup(each.value, "route53_records", {})) # revist
#   route53_records = {
#     create_internal_record = false
#     create_external_record = false
#   }
#   iam_resource_names_prefix = "instance"
#   instance_profile_policies = var.instance_profile_policies

#   user_data_raw = base64encode(var.user_data)

#   business_unit     = var.account_info.business_unit
#   application_name  = var.account_info.application_name
#   environment       = var.account_info.mp_environment
#   region            = "eu-west-2"
#   availability_zone = var.availability_zone
#   subnet_id         = var.subnet_id
#   tags = merge(var.tags,
#     { Name = "${var.account_info.application_name}-${var.env_name}-${var.db_suffix}-${local.instance_name_index}" },
#     { server-type = var.server_type_tag },
#     { database = local.database_tag },
#     var.enable_platform_backups != null ? { "backup" = var.enable_platform_backups ? "true" : "false" } : {}
#   )

#   cloudwatch_metric_alarms = merge(
#     local.cloudwatch_metric_alarms.ec2
#   )
# }
