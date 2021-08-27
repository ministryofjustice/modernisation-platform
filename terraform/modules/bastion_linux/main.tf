# get shared subnet-set vpc object
data "aws_vpc" "shared_vpc" {
  # provider = aws.share-host
  tags = {
    Name = "${var.business_unit}-${var.environment}"
  }
}

data "aws_subnet_ids" "local_account" {
  vpc_id = data.aws_vpc.shared_vpc.id
}

data "aws_subnet" "local_account" {
  for_each = data.aws_subnet_ids.local_account.ids
  id       = each.value
}

# get shared subnet-set private (az (a) subnet)
data "aws_subnet" "private_az_a" {
  # provider = aws.share-host
  tags = {
    Name = "${var.business_unit}-${var.environment}-${var.subnet_set}-private-${var.region}a"
  }
}

# get core_vpc account protected subnets security group
data "aws_security_group" "core_vpc_protected" {
  provider = aws.share-host

  tags = {
    Name = "${var.business_unit}-${var.environment}-int-endpoint"
  }
}

# get core_vpc account S3 endpoint
data "aws_vpc_endpoint" "s3" {
  provider     = aws.share-host
  vpc_id       = data.aws_vpc.shared_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  tags = {
    Name = "${var.business_unit}-${var.environment}-com.amazonaws.${var.region}.s3"
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
resource "aws_kms_key" "bastion_s3" {
  enable_key_rotation = true

  tags = merge(
    var.tags_common,
    {
      Name = "bastion_s3"
    },
  )
}

resource "aws_kms_alias" "bastion_s3_alias" {
  name          = "alias/s3-${var.bucket_name}_key"
  target_key_id = aws_kms_key.bastion_s3.arn
}

resource "aws_s3_bucket" "default" {
  bucket = "${var.tags_prefix}-${var.bucket_name}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bastion_s3.id
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
      Name = "bastion-linux"
    },
  )

}

resource "aws_s3_bucket_object" "bucket_public_keys_readme" {
  bucket     = aws_s3_bucket.default.id
  key        = "public-keys/README.txt"
  content    = "Drop here the ssh public keys of the instances you want to control"
  kms_key_id = aws_kms_key.bastion_s3.arn

  tags = merge(
    var.tags_common,
    {
      Name = "bastion-${var.app_name}-README.txt"
    }
  )

}

resource "aws_s3_bucket_object" "user_public_keys" {
  for_each = var.public_key_data

  bucket     = aws_s3_bucket.default.id
  key        = "public-keys/${each.key}.pub"
  content    = each.value
  kms_key_id = aws_kms_key.bastion_s3.arn

  tags = merge(
    var.tags_common,
    {
      Name = "bastion-${var.app_name}-${each.key}-publickey"
    }
  )

}

# Security Groups
resource "aws_security_group" "bastion_linux" {
  description = "Configure bastion access - ingress should be only from Systems Session Manager (SSM)"
  name        = "bastion-linux-${var.app_name}"
  vpc_id      = data.aws_vpc.shared_vpc.id

  tags = merge(
    var.tags_common,
    {
      Name = "bastion-linux-${var.app_name}"
    }
  )
}

resource "aws_security_group_rule" "basion_linux_egress_1" {
  security_group_id = aws_security_group.bastion_linux.id

  description = "bastion_linux_egress_of_HTTP_to_0.0.0.0/0"
  type        = "egress"
  from_port   = "80"
  to_port     = "80"
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "basion_linux_egress_2" {
  security_group_id = aws_security_group.bastion_linux.id

  description = "bastion_linux_egress_of_HTTPS_to_0.0.0.0/0"
  type        = "egress"
  from_port   = "443"
  to_port     = "443"
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "basion_linux_egress_3" {
  security_group_id = aws_security_group.bastion_linux.id

  description = "bastion_linux_to_local_subnet_CIDRs"
  type        = "egress"
  from_port   = "0"
  to_port     = "65535"
  protocol    = "TCP"
  cidr_blocks = [for s in data.aws_subnet.local_account : s.cidr_block]
}

resource "aws_security_group_rule" "basion_linux_egress_4" {
  security_group_id = aws_security_group.bastion_linux.id

  description              = "bastion_linux_egress_to_inteface_endpoints"
  type                     = "egress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "TCP"
  source_security_group_id = data.aws_security_group.core_vpc_protected.id
}

resource "aws_security_group_rule" "bastion_linux_egress_5" {
  security_group_id = aws_security_group.bastion_linux.id

  description     = "bastion_linux_egress_to_s3_endpoint"
  type            = "egress"
  from_port       = "443"
  to_port         = "443"
  protocol        = "TCP"
  prefix_list_ids = [data.aws_vpc_endpoint.s3.prefix_list_id]
}


# IAM
data "aws_iam_policy_document" "bastion_assume_policy_document" {
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

resource "aws_iam_role" "bastion_role" {
  name               = "bastion_linux_ec2_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_policy_document.json

  tags = merge(
    var.tags_common,
    {
      Name = "bastion_linux_ec2_role"
    },
  )
}

data "aws_iam_policy_document" "bastion_policy_document" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.default.arn}/logs/*"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = ["${aws_s3_bucket.default.arn}/public-keys/*"]
  }

  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
    aws_s3_bucket.default.arn]

    condition {
      test = "ForAnyValue:StringEquals"
      values = [
        "public-keys/",
        "logs/"
      ]
      variable = "s3:prefix"
    }
  }

  statement {
    actions = [

      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.bastion_s3.arn]
  }
}

resource "aws_iam_policy" "bastion_policy" {
  name   = "bastion"
  policy = data.aws_iam_policy_document.bastion_policy_document.json
}

resource "aws_iam_role_policy_attachment" "bastion_s3" {
  policy_arn = aws_iam_policy.bastion_policy.arn
  role       = aws_iam_role.bastion_role.name
}

resource "aws_iam_role_policy_attachment" "bastion_managed" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion_role.name
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
  role       = aws_iam_role.bastion_role.name
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-ec2-profile"
  role = aws_iam_role.bastion_role.name
  path = "/"
}

## Bastion

data "aws_ami" "linux_2_image" {
  most_recent = true
  owners      = ["amazon"]

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
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.id
  ebs_optimized               = true
  monitoring                  = false
  vpc_security_group_ids      = [aws_security_group.bastion_linux.id]
  subnet_id                   = data.aws_subnet.private_az_a.id

  root_block_device {
    encrypted = true
  }

  user_data = base64encode(data.template_file.user_data.rendered)

  metadata_options {
    http_endpoint               = "enabled" # defaults to enabled but is required if http_tokens is specified
    http_put_response_hop_limit = 1         # default is 1, value values are 1 through 64
    http_tokens                 = "required"
  }

  tags = merge(
    var.tags_common,
    {
      Name = "bastion_linux"
    }
  )
}
