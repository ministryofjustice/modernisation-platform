resource "helm_release" "gatekeeper" {
  name       = "gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  version    = "3.13.3"
  namespace  = kubernetes_namespace.gatekeeper_system.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/gatekeeper/values.yml.tftpl",
      {}
    )
  ]
  depends_on = [kubernetes_labels.kube_system]
}

resource "helm_release" "gatekeeper_constraint_templates" {
  name      = "gatekeeper-constraint-templates"
  chart     = "./src/helm/charts/gatekeeper-constraint-templates"
  namespace = kubernetes_namespace.gatekeeper_system.metadata[0].name

  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "gatekeeper_constraints" {
  name      = "gatekeeper-constraints"
  chart     = "./src/helm/charts/gatekeeper-constraints"
  namespace = kubernetes_namespace.gatekeeper_system.metadata[0].name

  depends_on = [helm_release.gatekeeper_constraint_templates]
}

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
  depends_on = [helm_release.gatekeeper]
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
  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.1"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/cert-manager/values.yml.tftpl",
      {
        eks_role_arn = module.cert_manager_role.iam_role_arn
      }
    )
  ]
  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "cert_manager_additional" {
  name      = "cert-manager-additional"
  chart     = "./src/helm/charts/cert-manager-additional"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  set {
    name  = "acme.email"
    value = "data-platform-tech+certificates@digital.justice.gov.uk"
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "aws.hostedZoneID"
    value = data.aws_route53_zone.apps_tools.zone_id
  }

  set {
    name  = "aws.dnsZone"
    value = local.environment_configuration.route53_zone
  }

  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "ingress_nginx_prerequisites" {
  name      = "ingress-nginx-prerequisites"
  chart     = "./src/helm/charts/ingress-nginx-prerequisites"
  namespace = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "ingressNginxDefaultCertificate.namespace"
    value = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  set {
    name  = "ingressNginxDefaultCertificate.dnsName"
    value = "*.${local.environment_configuration.route53_zone}"
  }

  depends_on = [helm_release.cert_manager_additional]
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.2"
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
  depends_on = [helm_release.gatekeeper, helm_release.ingress_nginx_prerequisites]
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "5.1.0"
  namespace  = kubernetes_namespace.velero_system.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/velero/values.yml.tftpl",
      {
        eks_role_arn              = module.velero_role.iam_role_arn
        velero_aws_plugin_version = "v1.8.0"
        velero_bucket             = module.velero_s3_bucket.bucket.id
        velero_prefix             = module.eks.cluster_name
        aws_region                = data.aws_region.current.name
      }
    )
  ]
  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.6"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/external-secrets/values.yml.tftpl",
      {
        eks_role_arn = module.external_secrets_role.iam_role_arn
      }
    )
  ]
  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "policy_controller" {
  name       = "policy-controller"
  repository = "https://sigstore.github.io/helm-charts"
  chart      = "policy-controller"
  version    = "0.6.5"
  namespace  = kubernetes_namespace.cosign_system.metadata[0].name
  values     = [templatefile("${path.module}/src/helm/policy-controller/values.yml.tftpl", {})]

  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "aws_for_fluent_bit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.30"
  namespace  = "kube-system"
  values = [
    templatefile(
      "${path.module}/src/helm/aws-for-fluent-bit/values.yml.tftpl",
      {
        aws_region   = data.aws_region.current.name
        cluster_name = module.eks.cluster_name
      }
    )
  ]

  depends_on = [helm_release.gatekeeper]
}

resource "helm_release" "openmetadata_dependencies" {
  name       = "openmetadata-dependencies"
  repository = "https://helm.open-metadata.org"
  chart      = "openmetadata-dependencies"
  version    = "1.1.14"
  namespace  = kubernetes_namespace.openmetadata.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/openmetadata-dependencies/values.yml.tftpl",
      {
        openmetadata_airflow_password                = random_password.openmetadata_airflow.result
        openmetadata_airflow_eks_role_arn            = module.openmetadata_airflow_iam_role.iam_role_arn
        openmetadata_airflow_rds_host                = module.openmetadata_airflow_rds.db_instance_address
        openmetadata_airflow_rds_user                = module.openmetadata_airflow_rds.db_instance_username
        openmetadata_airflow_rds_db                  = module.openmetadata_airflow_rds.db_instance_name
        openmetadata_airflow_rds_password_secret     = kubernetes_secret.openmetadata_airflow_rds_credentials.metadata[0].name
        openmetadata_airflow_rds_password_secret_key = "password"
        openmetadata_airflow_admin_email             = "${local.environment_configuration.airflow_mail_from_address}@${local.environment_configuration.ses_domain_identity}"
      }
    )
  ]
  wait    = true
  timeout = 600

  depends_on = [kubernetes_secret.openmetadata_airflow]
}

resource "helm_release" "openmetadata" {
  name       = "openmetadata"
  repository = "https://helm.open-metadata.org"
  chart      = "openmetadata"
  version    = "1.1.14"
  namespace  = kubernetes_namespace.openmetadata.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/openmetadata/values.yml.tftpl",
      {
        host                                 = "catalogue.${local.environment_configuration.route53_zone}"
        eks_role_arn                         = module.openmetadata_iam_role.iam_role_arn
        client_id                            = data.aws_secretsmanager_secret_version.openmetadata_entra_id_client_id.secret_string
        tenant_id                            = data.aws_secretsmanager_secret_version.openmetadata_entra_id_tenant_id.secret_string
        jwt_key_id                           = random_uuid.openmetadata_jwt.result
        openmetadata_airflow_username        = "${local.environment_configuration.airflow_mail_from_address}@${local.environment_configuration.ses_domain_identity}"
        openmetadata_airflow_password_secret = kubernetes_secret.openmetadata_airflow.metadata[0].name
        #checkov:skip=CKV_SECRET_6:Reference to Kubernetes secret not a sensitive value
        openmetadata_airflow_password_secret_key    = "openmetadata-airflow-password"
        openmetadata_opensearch_host                = resource.aws_opensearch_domain.openmetadata.endpoint
        openmetadata_opensearch_user                = "openmetadata"
        openmetadata_opensearch_password_secret     = kubernetes_secret.openmetadata_opensearch_credentials.metadata[0].name
        openmetadata_opensearch_password_secret_key = "password"
        openmetadata_rds_host                       = module.openmetadata_rds.db_instance_address
        openmetadata_rds_user                       = module.openmetadata_rds.db_instance_username
        openmetadata_rds_dbname                     = module.openmetadata_rds.db_instance_name
        openmetadata_rds_password_secret            = kubernetes_secret.openmetadata_rds_credentials.metadata[0].name
        openmetadata_rds_password_secret_key        = "password"
      }
    )
  ]
  wait    = true
  timeout = 600

  depends_on = [helm_release.openmetadata_dependencies]
}

resource "helm_release" "amazon_managed_prometheus_proxy" {
  name       = "prometheus-proxy"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.1.0"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  values = [
    templatefile(
      "${path.module}/src/helm/prometheus/values.yml.tftpl",
      {
        aws_account_id                  = data.aws_caller_identity.current.account_id
        aws_account_name                = "${local.application_name}-${local.environment}"
        aws_region                      = data.aws_region.current.name
        eks_role_arn                    = module.prometheus_iam_role.iam_role_arn
        cluster_name                    = module.eks.cluster_name
        prometheus_remote_write_url     = local.environment_configuration.observability_platform_prometheus_url
        observability_platform_role_arn = "arn:aws:iam::${local.environment_configuration.observability_platform_account_id}:role/${local.environment_configuration.observability_platform_role}"
      }
    )
  ]

  depends_on = [helm_release.gatekeeper]
}
