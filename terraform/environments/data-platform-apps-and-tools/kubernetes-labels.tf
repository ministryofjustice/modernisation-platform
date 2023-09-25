resource "kubernetes_labels" "kube_system" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
    "policy.sigstore.dev/include"    = "false"
  }
}
