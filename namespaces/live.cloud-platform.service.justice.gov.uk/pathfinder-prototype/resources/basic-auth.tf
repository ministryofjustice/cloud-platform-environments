# Username and password for the prototype kit website's http basic
# authentication
resource "random_password" "password" {
  length  = 16
  special = false
}

resource "kubernetes_secret" "basic-auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    username = var.basic-auth-username
    password = random_password.password.result
  }
}