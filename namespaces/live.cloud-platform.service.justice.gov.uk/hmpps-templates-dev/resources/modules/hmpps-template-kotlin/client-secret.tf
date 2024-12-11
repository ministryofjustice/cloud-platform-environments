# Generate a secure random session secret
resource "kubernetes_secret" "client_secret" {
  metadata {
    name      = "${var.application}-client-secret"
    namespace = var.namespace
  }
  data = {
    # Initial value for the client credentials
    API_CLIENT_ID = ""
    API_CLIENT_SECRET = ""
  }
  lifecycle {
    ignore_changes = [data]
  }
}
