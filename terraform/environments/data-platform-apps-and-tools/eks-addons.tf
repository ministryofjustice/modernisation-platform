resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = local.environment_configuration.eks_versions.addon_ebs_csi_driver
  service_account_role_arn = module.ebs_csi_driver_role.iam_role_arn

  tags = local.tags
}
