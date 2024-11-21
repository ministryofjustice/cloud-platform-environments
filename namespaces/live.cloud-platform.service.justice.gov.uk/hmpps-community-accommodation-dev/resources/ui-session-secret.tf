# Generate a secure random session secret
resource "random_password" "session_secret" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  number  = true
}
resource "kubernetes_secret" "session_secret" {
  metadata {
    name      = "session-secret"
    namespace = var.namespace
  }
  data = {
    secret_key = random_password.session_secret.result
  }
}
