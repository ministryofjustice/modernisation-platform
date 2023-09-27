# resource "kubernetes_storage_class" "efs" {
#   metadata {
#     name = "efs-sc"
#   }
#   storage_provisioner = "efs.csi.aws.com"

#   depends_on = [helm_release.aws_efs_csi_driver]
# }
