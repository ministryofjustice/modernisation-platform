resource "kubernetes_persistent_volume_claim" "openmetadata_airflow_dags" {
  metadata {
    name      = "openmetadata-dependencies-dags-pvc"
    namespace = kubernetes_namespace.openmetadata.metadata[0].name
    labels = {
      app = "openmetadata-airflow-dags"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "efs-sc"
    volume_name        = kubernetes_persistent_volume.openmetadata_airflow_dags.metadata[0].name
  }
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim" "openmetadata_airflow_logs" {
  metadata {
    name      = "openmetadata-dependencies-logs-pvc"
    namespace = kubernetes_namespace.openmetadata.metadata[0].name
    labels = {
      app = "openmetadata-airflow-logs"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
    storage_class_name = "efs-sc"
    volume_name        = kubernetes_persistent_volume.openmetadata_airflow_logs.metadata[0].name
  }
  wait_until_bound = false
}