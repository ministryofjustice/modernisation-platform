resource "kubernetes_secret" "openmetadata_airflow" {
  metadata {
    name      = "airflow-secrets"
    namespace = kubernetes_namespace.open_metadata.metadata[0].name
  }
  data = {
    openmetadata-airflow-password = random_password.openmetadata_airflow.result
  }
  type = "Opaque"
}

resource "kubernetes_secret" "openmetadata_airflow_rds_credentials" {
  metadata {
    name      = "openmetadata-airflow-rds-credentials"
    namespace = kubernetes_namespace.open_metadata.metadata[0].name
  }
  data = {
    username = local.openmetadata_airflow_rds_credentials.username
    password = local.openmetadata_airflow_rds_credentials.password
  }
  type = "Opaque"
}
