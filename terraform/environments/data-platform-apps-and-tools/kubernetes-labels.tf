resource "kubernetes_labels" "kube_system" {
  api_version = "v1"
  kind        = "Namespace"
  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
  }
}
