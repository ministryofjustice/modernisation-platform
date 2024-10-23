

# S3 bucket to store the inventory data in Account A
resource "aws_s3_bucket" "ssm_inventory_bucket" {
  bucket = "ssm-inventory-sync-bucket-236861075084-euw2"
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "ssm_inventory_bucket" {
  bucket = aws_s3_bucket.ssm_inventory_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Role in Account A for Systems Manager to assume and sync inventory data
resource "aws_iam_role" "ssm_sync_role" {
  name = "SSMSyncRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ssm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for Systems Manager to access S3 bucket in Account A
resource "aws_iam_policy" "ssm_sync_policy" {
  name = "SSMSyncPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::ssm-inventory-sync-bucket-236861075084-euw2",
        "arn:aws:s3:::ssm-inventory-sync-bucket-236861075084-euw2/*"
      ]
    }
  ]
}
EOF
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "ssm_sync_policy_attach" {
  role       = aws_iam_role.ssm_sync_role.name
  policy_arn = aws_iam_policy.ssm_sync_policy.arn
}

# S3 bucket policy to allow cross-account access for Account B and Account A
resource "aws_s3_bucket_policy" "ssm_inventory_bucket_policy" {
  bucket = aws_s3_bucket.ssm_inventory_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::236861075084:root",
          "arn:aws:iam::348456244381:root"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::ssm-inventory-sync-bucket-236861075084-euw2/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ssm.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::ssm-inventory-sync-bucket-236861075084-euw2/*"
    }
  ]
}
EOF
}

# Create Resource Data Sync in Account A to sync data to the S3 bucket
resource "aws_ssm_resource_data_sync" "account_a_data_sync" {
  name = "ResourceDataSyncAccountA"
  s3_destination {
    bucket_name = "ssm-inventory-sync-bucket-236861075084-euw2"
    region      = "eu-west-2"
    sync_format = "JsonSerDe"
    prefix      = "ssm-data-sync/"   # Added prefix to store data under this folder
  }
}

resource "aws_ssm_association" "ssm_inventory" {
  name = "AWS-GatherSoftwareInventory"
  
  schedule_expression = "rate(30 minutes)"
  targets {
    key    = "InstanceIds"
    values = ["i-0474ba7a45b548e96"]
  }
}