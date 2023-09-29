module "efs" {
  #checkov:skip=CKV_TF_1:Module is from Terraform registry

  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.0"

  name          = "openmetadata"
  encrypted     = false
  kms_key_arn   = module.kms.openmetadata_efs_kms.key_arn
  attach_policy = false

  enable_backup_policy = true

  mount_targets = {
    "private-subnets-0" = {
      subnet_id = module.vpc.private_subnets[0]
    }
    "private-subnets-1" = {
      subnet_id = module.vpc.private_subnets[1]
    }
    "private-subnets-2" = {
      subnet_id = module.vpc.private_subnets[2]
    }
  }

  security_group_vpc_id = module.vpc.vpc_id
  security_group_rules = {
    private-subnets = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  access_points = {
    airflow_dags = {
      name = "airflow-dags"
      posix_user = {
        gid = 50000
        uid = 50000
      }
      root_directory = {
        path = "/airflow-dags"
        creation_info = {
          owner_gid   = 50000
          owner_uid   = 50000
          permissions = "775"
        }
      }
    }
    airflow_logs = {
      name = "airflow-logs"
      posix_user = {
        gid = 50000
        uid = 50000
      }
      root_directory = {
        path = "/airflow-logs"
        creation_info = {
          owner_gid   = 50000
          owner_uid   = 50000
          permissions = "775"
        }
      }
    }
  }
}