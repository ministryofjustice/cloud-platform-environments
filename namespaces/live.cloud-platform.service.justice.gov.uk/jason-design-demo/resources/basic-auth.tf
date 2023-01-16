# Username and password for the prototype kit website's http basic
# authentication
resource "kubernetes_secret" "basic-auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    username = "basic-no-need-to-panic-username"
    password = var.basic-auth-password
  }
}
