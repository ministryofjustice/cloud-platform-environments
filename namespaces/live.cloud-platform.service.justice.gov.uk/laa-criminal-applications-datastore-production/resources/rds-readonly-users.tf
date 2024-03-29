resource "random_password" "password_metabase" {
  length  = 32
  special = false

  keepers = {
    last_changed = "2023-06-26"
  }
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "rds-readonly-users"
    namespace = var.namespace
  }

  data = {
    metabase = random_password.password_metabase.result
  }
}
