resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.29.3"
  namespace  = "kube-system"

  values = [
    templatefile(
      "${path.module}/src/helm/cluster-autoscaler/values.yml.tftpl",
      {
        aws_region   = data.aws_region.current.name
        cluster_name = module.eks.cluster_name
        eks_role_arn = module.cluster_autoscaler_role.iam_role_arn
      }
    )
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = "1.13.1"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/external-dns/values.yml.tftpl",
      {
        domain_filter = local.environment_configuration.route53_zone
        eks_role_arn  = module.external_dns_role.iam_role_arn
      }
    )
  ]
}
