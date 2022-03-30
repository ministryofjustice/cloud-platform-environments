resource "kubernetes_secret" "basic-auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    auth = var.basic-auth-value
  }
}
