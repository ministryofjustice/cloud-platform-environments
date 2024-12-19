# Generate a secure random session secret
resource "random_password" "session_secret" {
  length  = 43
  special = false
  upper   = true
  lower   = true
  numeric = true
}
resource "kubernetes_secret" "session_secret" {
  metadata {
    name      = "${var.application}-session-secret"
    namespace = var.namespace
  }
  data = {
    SESSION_SECRET = random_password.session_secret.result
  }
}
