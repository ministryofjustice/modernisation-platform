resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "velero_system" {
  metadata {
    name = "velero-system"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "gatekeeper_system" {
  metadata {
    name = "gatekeeper-system"
    labels = {
      "admission.gatekeeper.sh/ignore" = "no-self-managing"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "cosign_system" {
  metadata {
    name = "cosign-system"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
    labels = {
      "admission.gatekeeper.sh/ignore" = "false"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}
