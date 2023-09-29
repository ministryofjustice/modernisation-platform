resource "random_password" "openmetadata_airflow" {
  length  = 32
  special = false
}