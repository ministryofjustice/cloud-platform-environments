# Username and password for the prototype kit website's http basic
# authentication
resource "kubernetes_secret" "basic_auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    username = var.basic-auth-username
    password = var.basic-auth-password
  }
}
