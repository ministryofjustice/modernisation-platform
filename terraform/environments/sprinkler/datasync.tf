
# IAM Role in Account B to allow cross-account access to S3 in Account A
resource "aws_iam_role" "ssm_inventory_sync_role" {
  name = "SSMInventorySyncRole"

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

# IAM Policy for the role to allow writing to the S3 bucket in Account A
resource "aws_iam_policy" "ssm_inventory_sync_policy" {
  name = "SSMInventorySyncPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::ssm-inventory-sync-bucket-euw2",
        "arn:aws:s3:::ssm-inventory-sync-bucket-euw2/*"
      ]
    }
  ]
}
EOF
}

# Attach the policy to the role in Account B
resource "aws_iam_role_policy_attachment" "ssm_inventory_sync_policy_attach" {
  role       = aws_iam_role.ssm_inventory_sync_role.name
  policy_arn = aws_iam_policy.ssm_inventory_sync_policy.arn
}


resource "aws_ssm_association" "ssm_inventory" {
  name = "AWS-GatherSoftwareInventory"
  schedule_expression = ""
  targets {
    key    = "InstanceIds"
    values = [""]
  }
}

# Create Resource Data Sync in Account A to sync data to the S3 bucket
resource "aws_ssm_resource_data_sync" "account_a_data_sync" {
  name = "ResourceDataSyncAccountA"
  s3_destination {
    bucket_name = "ssm-inventory-sync-bucket-euw2"
    region      = "eu-west-2"
    sync_format = "JsonSerDe"
    prefix      = "ssm-data-sync/"   # Added prefix to store data under this folder
  }
}