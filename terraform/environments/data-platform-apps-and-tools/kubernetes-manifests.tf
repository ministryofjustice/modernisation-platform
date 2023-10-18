# resource "kubernetes_manifest" "cert_manager_cluster_issuer_letsencrypt_production" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "ClusterIssuer"
#     "metadata" = {
#       "name" = "letsencrypt-production"
#     }
#     "spec" = {
#       "acme" = {
#         "email"  = "data-platform-tech+certificates@digital.justice.gov.uk"
#         "server" = "https://acme-v02.api.letsencrypt.org/directory"
#         "privateKeySecretRef" = {
#           "name" = "letsencrypt-production"
#         }
#         "solvers" = [
#           {
#             "dns01" = {
#               "cnameStrategy" = "Follow"
#               "route53" = {
#                 "region"       = data.aws_region.current.name
#                 "hostedZoneID" = data.aws_route53_zone.apps_tools.zone_id
#               }
#             }
#           }
#         ]
#       }
#     }
#   }

#   depends_on = [helm_release.cert_manager]
# }

# resource "kubernetes_manifest" "cert_manager_ingress_nginx_default_certificate" {
#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "Certificate"
#     "metadata" = {
#       "name"      = "default-certificate"
#       "namespace" = kubernetes_namespace.ingress_nginx.metadata[0].name
#     }
#     "spec" = {
#       "secretName" = "default-certificate"
#       "issuerRef" = {
#         "kind" = "ClusterIssuer"
#         "name" = "letsencrypt-production"
#       }
#       "dnsNames" = [
#         "*.${local.environment_configuration.route53_zone}"
#       ]
#     }
#   }

#   depends_on = [kubernetes_manifest.cert_manager_cluster_issuer_letsencrypt_production]
# }
