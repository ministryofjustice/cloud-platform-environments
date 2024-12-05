# Username and password for the website's basic authentication
resource "kubernetes_secret" "basic-auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    username = var.basic-auth-username
    password = var.basic-auth-password
  }
}
