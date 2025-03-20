resource "kubernetes_secret" "password" {
  metadata {
    name      = "password"
    namespace = var.namespace
  }

  data = {
    password = var.password
  }
}
