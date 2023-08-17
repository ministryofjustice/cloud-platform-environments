resource "random_password" "api_token" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "api_token" {
  metadata {
    name      = "api-token"
    namespace = var.namespace
  }

  data = {
    api_token = random_password.api_token.result
  }
}
