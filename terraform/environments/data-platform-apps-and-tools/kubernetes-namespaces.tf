resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }

  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }

  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
  }
}

resource "kubernetes_namespace" "velero_system" {
  metadata {
    name = "velero-system"
  }

  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
  }
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }

  labels = {
    "admission.gatekeeper.sh/ignore" = "true"
  }
}

resource "kubernetes_namespace" "gatekeeper_system" {
  metadata {
    name = "gatekeeper-system"
  }
}
