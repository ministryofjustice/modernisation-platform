resource "kubernetes_manifest" "cert_manager_cluster_issuer_letsencrypt_production" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-production"
    }
    "spec" = {
      "acme" = {
        "email"  = "data-platform-tech+certificates@digital.justice.gov.uk"
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-production"
        }
        "solvers" = [
          {
            "dns01" = {
              "cnameStrategy" = "Follow"
              "route53" = {
                "region"       = data.aws_region.current.name
                "hostedZoneID" = data.aws_route53_zone.apps_tools.zone_id
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}
