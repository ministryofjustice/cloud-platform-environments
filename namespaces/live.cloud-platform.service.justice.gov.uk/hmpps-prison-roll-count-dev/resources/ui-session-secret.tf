resource "random_password" "session_secret" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "session_secret" {
  metadata {
    name      = "session-secret"
    namespace = var.namespace
  }

  data = {
    SESSION_SECRET = random_password.session_secret.result
  }
}
