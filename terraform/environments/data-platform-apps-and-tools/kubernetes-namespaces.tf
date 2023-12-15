resource "kubernetes_namespace" "gatekeeper_system" {
  metadata {
    name = "gatekeeper-system"
    labels = {
      "admission.gatekeeper.sh/ignore" = "no-self-managing"
      "policy.sigstore.dev/include"    = "false"
    }
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "velero_system" {
  metadata {
    name = "velero-system"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "cosign_system" {
  metadata {
    name = "cosign-system"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted" // https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted
      "policy.sigstore.dev/include"        = "false"      // this will eventually be true, but we aren't currently signing images
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "openmetadata" {
  metadata {
    name = "openmetadata"
    labels = {
      "policy.sigstore.dev/include" = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "static_assets" {
  metadata {
    name = "static-assets"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}

resource "kubernetes_namespace" "actions_runners" {
  metadata {
    name = "actions-runners"
    labels = {
      "admission.gatekeeper.sh/ignore" = "true"
      "policy.sigstore.dev/include"    = "false"
    }
  }
  depends_on = [helm_release.gatekeeper]
}
