// Derived from https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-eks-example.html#eksctl-role
resource "kubernetes_role_binding" "airflow" {
  metadata {
    name      = "airflow-role-binding"
    namespace = kubernetes_namespace.airflow.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.airflow.metadata[0].name
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Group"
    name      = "airflow"
  }
}
