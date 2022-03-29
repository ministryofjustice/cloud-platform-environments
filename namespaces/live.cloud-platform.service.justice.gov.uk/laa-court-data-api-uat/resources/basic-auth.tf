resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "basic-auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    username = var.basic-auth-username
    password = random_password.password.result
  }
}
