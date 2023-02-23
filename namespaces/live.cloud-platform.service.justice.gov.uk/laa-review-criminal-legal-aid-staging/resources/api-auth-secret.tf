data "kubernetes_secret" "datastore-api-auth-secrets" {
  metadata {
    name      = "api-auth-secrets"
    namespace = "laa-criminal-applications-datastore-staging"
  }
}

resource "kubernetes_secret" "datastore-api-auth-secret" {
  metadata {
    name      = "datastore-api-auth-secret"
    namespace = var.namespace
  }

  data = {
    secret = data.kubernetes_secret.datastore-api-auth-secrets.data.crime_review
  }
}
