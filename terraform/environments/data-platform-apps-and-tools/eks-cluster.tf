# module "eks" {
#   #checkov:skip=CKV_TF_1:Module is from Terraform registry

#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.16.0"

#   cluster_name    = local.eks_cluster_name
#   cluster_version = "1.27"

#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.private_subnets
#   control_plane_subnet_ids = module.vpc.private_subnets

#   # TODO: Pin versions of these addons
#   cluster_addons = {
#     coredns = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#     aws-ebs-csi-driver = {
#       most_recent              = true
#       service_account_role_arn = module.ebs_csi_driver_role.iam_role_arn
#     }
#     vpc-cni = {
#       most_recent              = true
#       service_account_role_arn = module.vpc_cni_role.iam_role_arn
#     }
#   }

#   eks_managed_node_group_defaults = {
#     iam_role_additional_policies = {
#       AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#     }
#   }

#   # TODO: Review these settings
#   eks_managed_node_groups = {
#     general = {
#       min_size       = 1
#       max_size       = 10
#       desired_size   = 1
#       instance_types = ["t3.large", "t3a.large"]
#       tags = {
#         Name = "${local.eks_cluster_name}-general"
#       }
#     }
#   }

#   manage_aws_auth_configmap = true

#   # TODO: source this role somehow
#   aws_auth_roles = [
#     {
#       groups   = ["system:masters"]
#       rolearn  = "arn:aws:iam::335889174965:role/AWSReservedSSO_modernisation-platform-sandbox_2aca2601d47bffe3"
#       username = "administrator"
#     }
#   ]
# }
