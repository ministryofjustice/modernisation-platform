resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}
