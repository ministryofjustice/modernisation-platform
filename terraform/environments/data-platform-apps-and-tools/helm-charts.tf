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

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.0"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/cert-manager/values.yml.tftpl",
      {
        eks_role_arn = module.cert_manager_role.iam_role_arn
      }
    )
  ]
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.2"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/ingress-nginx/values.yml.tftpl",
      {
        default_ssl_certificate = "${kubernetes_namespace.ingress_nginx.metadata[0].name}/default-certificate"
        ingress_hostname        = "ingress.${local.environment_configuration.route53_zone}"
      }
    )
  ]
}

resource "helm_release" "aws_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = "2.4.9"
  namespace  = "kube-system"
  values = [
    templatefile(
      "${path.module}/src/helm/aws-efs-csi-driver/values.yml.tftpl",
      {
        eks_role_arn = module.efs_csi_driver_role.iam_role_arn
      }
    )
  ]
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "5.0.2"
  namespace  = kubernetes_namespace.velero_system.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/velero/values.yml.tftpl",
      {
        eks_role_arn              = module.velero_role.iam_role_arn
        velero_aws_plugin_version = "v1.7.0"
        velero_bucket             = module.eks_backup_bucket.bucket.id
        velero_prefix             = module.eks.cluster_name
        aws_region                = data.aws_region.current.name
      }
    )
  ]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.4"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/external-secrets/values.yml.tftpl",
      {
        eks_role_arn = module.external_secrets_role.iam_role_arn
      }
    )
  ]
}

resource "helm_release" "gatekeeper" {
  name       = "gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  version    = "3.13.0"
  namespace  = kubernetes_namespace.gatekeeper_system.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/gatekeeper/values.yml.tftpl",
      {}
    )
  ]
  depends_on = [kubernetes_labels.kube_system]
}
