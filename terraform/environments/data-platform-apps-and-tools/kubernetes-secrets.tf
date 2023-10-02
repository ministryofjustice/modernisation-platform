resource "kubernetes_secret" "openmetadata_airflow" {
  metadata {
    name      = "openmetadata-airflow"
    namespace = kubernetes_namespace.openmetadata.metadata[0].name
  }
  data = {
    openmetadata-airflow-password = random_password.openmetadata_airflow.result
  }
  type = "Opaque"
}

resource "kubernetes_secret" "openmetadata_airflow_rds_credentials" {
  metadata {
    name      = "openmetadata-airflow-rds-credentials"
    namespace = kubernetes_namespace.openmetadata.metadata[0].name
  }
  data = {
    username = "airflow"
    password = random_password.openmetadata_airflow.result
  }
  type = "Opaque"
}
