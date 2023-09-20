module "eks" {
  #checkov:skip=CKV_TF_1:Module is from Terraform registry

  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name    = local.eks_cluster_name
  cluster_version = "1.27"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  control_plane_subnet_ids = module.vpc.private_subnets
  subnet_ids               = module.vpc.private_subnets

  # TODO: Pin versions of these addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

  # TODO: Review these settings
  eks_managed_node_groups = {
    general = {
      min_size       = 1
      max_size       = 10
      desired_size   = 1
      instance_types = ["t3.large", "t3a.large"]
    }
  }

  manage_aws_auth_configmap = true

  # TODO: source this role somehow
  aws_auth_roles = [
    {
      groups   = ["system:masters"]
      rolearn  = one(data.aws_iam_roles.eks_sso_access_role.arns)
      username = "administrator"
    }
  ]
}
