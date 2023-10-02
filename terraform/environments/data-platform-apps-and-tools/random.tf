resource "random_password" "openmetadata_airflow" {
  length  = 32
  special = false
}

resource "random_password" "openmetadata" {
  length  = 32
  special = false
}

resource "random_password" "opensearch" {
  length  = 32
  special = false
}