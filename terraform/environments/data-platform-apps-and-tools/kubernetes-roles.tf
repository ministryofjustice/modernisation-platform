// Derived from https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-eks-example.html#eksctl-role
resource "kubernetes_role" "airflow" {
  metadata {
    name      = "airflow-role"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }
  rule {
    api_groups = [
      "",
      "apps",
      "batch",
      "extensions",
    ]
    resources = [
      "jobs",
      "pods",
      "pods/attach",
      "pods/exec",
      "pods/log",
      "pods/portforward",
      "secrets",
      "services"
    ]
    verbs = [
      "create",
      "delete",
      "describe",
      "get",
      "list",
      "patch",
      "update"
    ]
  }
}
