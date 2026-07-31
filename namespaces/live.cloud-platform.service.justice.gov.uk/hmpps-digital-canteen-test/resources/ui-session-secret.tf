resource "random_password" "hmpps-digital-canteen-ui-session-secret" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "hmpps-digital-canteen-ui-session-secret" {
  metadata {
    name      = "hmpps-digital-canteen-ui-session-secret"
    namespace = var.namespace
  }

  data = {
    SESSION_SECRET = random_password.session_secret.result
  }
}
