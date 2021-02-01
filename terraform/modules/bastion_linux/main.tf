provider "aws" {
  alias = "share-host" # Provider that holds the resource share
}

provider "aws" {
  alias = "share-tenant" # Provider that wants to be shared with
}

# extract environment name from workspace name
locals {

##############################################################################
## TEMP override whilst using sandbox type accounts, UNCOMMENT THE BELOW LINE
## Delete static line below it
##############################################################################
  # environment_name = trimprefix(terraform.workspace, "${var.account_name}-")
  environment_name = "production"

}

# get shared subnet-set vpc object
data "aws_vpc" "shared_vpc" {
  provider = aws.share-host
  tags = {
    Name = "${var.business_unit}-${local.environment_name}"
  }
}

# get shared subnet-set private (az (a) subnet)
data "aws_subnet" "private_az_a" {
  provider = aws.share-host
  tags = {
    Name = "${var.business_unit}-${local.environment_name}-${var.subnet_set}-private-${var.region}a"
  }
}

# get core_vpc account protected subnets security group
data "aws_security_group" "core_vpc_protected" {
  provider = aws.share-host
  tags = {
    Name = "${var.subnet_set}_SSM"
  }
}

# get core_vpc account S3 endpoint
data "aws_vpc_endpoint" "s3" {
  provider     = aws.share-host
  vpc_id       = data.aws_vpc.shared_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  tags = {
    Name = "${var.business_unit}-${local.environment_name}-com.amazonaws.${var.region}.s3"
  }

}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    aws_region              = var.region
    bucket_name             = "${var.tags_prefix}-${var.bucket_name}"
    extra_user_data_content = var.extra_user_data_content
    allow_ssh_commands      = var.allow_ssh_commands
  }
}

# S3
resource "aws_kms_key" "key" {

  tags = merge(
    var.tags_common,
    {
      Name = "bastion"
    },
  )
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.tags_prefix}-${var.bucket_name}"
  target_key_id = aws_kms_key.key.arn
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.tags_prefix}-${var.bucket_name}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }


  force_destroy = var.bucket_force_destroy

  versioning {
    enabled = var.bucket_versioning
  }

  lifecycle_rule {
    id      = "log"
    enabled = var.log_auto_clean

    prefix = "logs/"

    tags = {
      rule      = "log"
      autoclean = var.log_auto_clean
    }

    transition {
      days          = var.log_standard_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.log_glacier_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.log_expiry_days
    }
  }

  tags = merge(
    var.tags_common,
    {
      Name = "bastion"
    },
  )
  
  }

resource "aws_s3_bucket_object" "bucket_public_keys_readme" {
  bucket     = aws_s3_bucket.bucket.id
  key        = "public-keys/README.txt"
  content    = "Drop here the ssh public keys of the instances you want to control"
  kms_key_id = aws_kms_key.key.arn
}

# Security Groups
resource "aws_security_group" "bastion_linux" {
  description = "Configure bastion access - ingress should be only from Systems Session Manager (SSM)"
  name        = "${var.tags_prefix}-host"
  vpc_id      = data.aws_vpc.shared_vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "bastion_linux"
    }
  )
}
resource "aws_security_group_rule" "bastion_linux_egress_to_inteface_endpoints" {
  security_group_id        = aws_security_group.bastion_linux.id

  description              = "Outgoing traffic from linux bastion"
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "TCP"
  source_security_group_id = data.aws_security_group.core_vpc_protected.id
}
resource "aws_security_group_rule" "bastion_linux_egress_to_s3_endpoint" {
  security_group_id        = aws_security_group.bastion_linux.id

  description              = "Outgoing traffic from linux bastion"
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "TCP"
  prefix_list_ids          = [data.aws_vpc_endpoint.s3.prefix_list_id]
}


# IAM
data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bastion_host_role" {
  name               = "bastion_linux_ec2_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_document.json

  tags = merge(
    var.tags_common,
    {
      Name ="bastion_linux_ec2_role"
    },
  )

}

data "aws_iam_policy_document" "bastion_host_policy_document" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${aws_s3_bucket.bucket.arn}/logs/*"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.bucket.arn}/public-keys/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
    aws_s3_bucket.bucket.arn]

    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["public-keys/"]
      variable = "s3:prefix"
    }
  }

  statement {
    actions = [

      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.key.arn]
  }

}

resource "aws_iam_policy" "bastion_host_policy" {
  name   = "bastion"
  policy = data.aws_iam_policy_document.bastion_host_policy_document.json
}

resource "aws_iam_role_policy_attachment" "bastion_host_s3" {
  policy_arn = aws_iam_policy.bastion_host_policy.arn
  role       = aws_iam_role.bastion_host_role.name
}

resource "aws_iam_role_policy_attachment" "bastion_host_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_host_role.name
}

data "aws_iam_policy_document" "bastion_ssm_s3_policy_document" {

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
        "arn:aws:s3:::aws-ssm-${var.region}/*",
        "arn:aws:s3:::aws-windows-downloads-${var.region}/*",
        "arn:aws:s3:::amazon-ssm-${var.region}/*",
        "arn:aws:s3:::amazon-ssm-packages-${var.region}/*",
        "arn:aws:s3:::${var.region}-birdwatcher-prod/*",
        "arn:aws:s3:::aws-ssm-distributor-file-${var.region}/*",
        "arn:aws:s3:::aws-ssm-document-attachments-${var.region}/*",
        "arn:aws:s3:::patch-baseline-snapshot-${var.region}/*"
    ]
    }
}
resource "aws_iam_policy" "bastion_ssm_s3_policy" {
  name   = "bastion_ssm_s3"
  policy = data.aws_iam_policy_document.bastion_ssm_s3_policy_document.json
}

resource "aws_iam_role_policy_attachment" "bastion_host_ssm_s3" {
  policy_arn = aws_iam_policy.bastion_ssm_s3_policy.arn
  role       = aws_iam_role.bastion_host_role.name
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  role = aws_iam_role.bastion_host_role.name
  path = "/"
}

## Bastion

data "aws_ami" "linux_2_image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion_linux" {
  instance_type = "t3.micro"

  ami                         = data.aws_ami.linux_2_image.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.bastion_host_profile.id
  key_name                    = var.bastion_host_key_pair
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.bastion_linux.id]
  subnet_id                   = data.aws_subnet.private_az_a.id


  user_data = base64encode(data.template_file.user_data.rendered)

  tags = merge(
    var.tags_common,
    {
      Name ="bastion_linux"
    }
  )
}

# output "test" {
#   value = local.environment_name
# }