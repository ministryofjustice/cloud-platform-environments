resource "random_password" "passwords" {
  count   = 2
  length  = 20
  special = true
}

resource "kubernetes_secret" "api-auth-secrets" {
  metadata {
    name      = "api-auth-secrets"
    namespace = var.namespace
  }

  data = {
    crime_apply  = random_password.passwords[0].result
    crime_review = random_password.passwords[1].result
  }
}
