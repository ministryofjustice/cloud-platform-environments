# Generate a secure random session secret
resource "kubernetes_secret" "client_secret" {
  count = var.client_secret ? 1 : 0
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
