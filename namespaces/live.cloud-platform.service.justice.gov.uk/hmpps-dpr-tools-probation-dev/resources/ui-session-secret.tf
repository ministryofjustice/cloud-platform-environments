resource "random_password" "session_secret" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "session_secret" {
  metadata {
    name      = "ui-session-secret"
    namespace = var.namespace
  }

  data = {
    session_secret = random_password.session_secret.result
  }
}
