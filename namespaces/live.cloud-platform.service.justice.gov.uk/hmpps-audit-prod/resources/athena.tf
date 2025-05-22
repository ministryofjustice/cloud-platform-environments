resource "kubernetes_secret" "glue-database-name-secret" {
  metadata {
    name      = "glue-database-name"
    namespace = var.namespace
  }
  data = {
    database_arn  = "placeholder value"
    database_name = "placeholder-value"
  }
}

resource "kubernetes_secret" "glue-catalog-table-name-secret" {
  metadata {
    name      = "glue-catalog-table-name"
    namespace = var.namespace
  }
  data = {
    table_arn  = "placeholder value"
    table_name = "placeholder value"
  }
}

resource "kubernetes_secret" "athena-workgroup-secret" {
  metadata {
    name      = "athena-workgroup-secret"
    namespace = var.namespace
  }
  data = {
    workgroup_arn  = "placeholder-value"
    workgroup_name = "placeholder-value"
  }
}

resource "kubernetes_secret" "athena-output-location-secret" {
  metadata {
    name      = "athena-output-location-secret"
    namespace = var.namespace
  }
  data = {
    output_location = "placeholder-value"
  }
}
