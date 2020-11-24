# Backend
terraform {
  # `backend` blocks do not support variables, so the following are hard-coded here:
  # - S3 bucket name, which is created in s3.tf
  backend "s3" {
    acl                  = "bucket-owner-full-control"
    bucket               = "modernisation-platform-terraform-state"
    encrypt              = true
    key                  = "terraform.tfstate"
    region               = "eu-west-2"
    workspace_key_prefix = "environments/bootstrap" # This will store the object as environments/bootstrap/${workspace}/terraform.tfstate
  }
}

module "cross-account-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-cross-account-access"
  providers = {
    aws = aws.workspace
  }
  account_id = local.modernisation_platform_account.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role_name  = "ModernisationPlatformAccess"
}

module "baselines" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines"
  providers = {
    # Default and replication regions
    aws                    = aws.workspace-eu-west-2
    aws.replication-region = aws.workspace-eu-west-1

    # Other regions
    aws.ap-northeast-1 = aws.workspace-ap-northeast-1
    aws.ap-northeast-2 = aws.workspace-ap-northeast-2
    aws.ap-south-1     = aws.workspace-ap-south-1
    aws.ap-southeast-1 = aws.workspace-ap-southeast-1
    aws.ap-southeast-2 = aws.workspace-ap-southeast-2
    aws.ca-central-1   = aws.workspace-ca-central-1
    aws.eu-central-1   = aws.workspace-eu-central-1
    aws.eu-north-1     = aws.workspace-eu-north-1
    aws.eu-west-1      = aws.workspace-eu-west-1
    aws.eu-west-2      = aws.workspace-eu-west-2
    aws.eu-west-3      = aws.workspace-eu-west-3
    aws.sa-east-1      = aws.workspace-sa-east-1
    aws.us-east-1      = aws.workspace-us-east-1
    aws.us-east-2      = aws.workspace-us-east-2
    aws.us-west-1      = aws.workspace-us-west-1
    aws.us-west-2      = aws.workspace-us-west-2
  }
  root_account_id = local.root_account.master_account_id
  tags            = local.environments
}
