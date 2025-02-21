# Username and password for the prototype kit website's http basic
# authentication
resource "kubernetes_secret" "basic_auth" {
  metadata {
    name      = "basic-auth"
    namespace = var.namespace
  }

  data = {
    username = random_string.username
    password = random_password.password
  }
}

resource "random_string" "username" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  special          = false
}

resource "random_password" "password" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}