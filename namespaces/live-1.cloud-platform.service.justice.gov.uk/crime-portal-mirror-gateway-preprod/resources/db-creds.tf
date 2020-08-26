resource "random_password" "owner_password" {
  length  = 16
  special = true
}

resource "random_password" "user_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "pict_cpmg_db_credentials" {
  metadata {
    name      = "pict-cpmg-db-credentials"
    namespace = var.namespace
  }

  data = {
    owner          = "cpmg_db_owner"
    owner-password = random_password.owner_password.result
    user           = "cpmg_db_user"
    user-password  = random_password.user_password.result
  }
}
