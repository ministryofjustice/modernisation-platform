module "eks" {
  #checkov:skip=CKV_TF_1:Module is from Terraform registry

  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = local.environment_configuration.eks_cluster_name
  cluster_version = local.environment_configuration.eks_versions.cluster

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets
  subnet_ids               = module.vpc.private_subnets

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  cluster_addons = {
    coredns = {
      addon_version = local.environment_configuration.eks_versions.addon_coredns
    }
    kube-proxy = {
      addon_version = local.environment_configuration.eks_versions.addon_kube_proxy
    }
    vpc-cni = {
      addon_version = local.environment_configuration.eks_versions.addon_vpc_cni
    }
    aws-guardduty-agent = {
      addon_version = local.environment_configuration.eks_versions.addon_aws_guardduty_agent
    }
  }

  eks_managed_node_group_defaults = {
    ami_release_version = local.environment_configuration.eks_versions.ami_release
    ami_type            = "BOTTLEROCKET_x86_64"
    platform            = "bottlerocket"
    metadata_options = {
      http_endpoint               = "enabled"
      http_put_response_hop_limit = 2
      http_tokens                 = "required"
      instance_metadata_tags      = "enabled"
    }

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 100
        }
      }
    }

    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
  }

  // TODO: Review these settings
  eks_managed_node_groups = {
    general = {
      min_size       = 1
      max_size       = 10
      desired_size   = 3
      instance_types = ["t3.xlarge"]
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${one(data.aws_iam_roles.eks_sso_access_role.names)}"
      groups   = ["system:masters"]
      username = "administrator"
    },
    {
      // rolearn cannot consume module.airflow_execution_role.arn because that role consumes module.eks.cluster_arn, but we can construct the ARN manually
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.environment_configuration.airflow_execution_role_name}"
      groups   = ["airflow"]
      username = "airflow"
    }
  ]

  tags = local.tags
}
