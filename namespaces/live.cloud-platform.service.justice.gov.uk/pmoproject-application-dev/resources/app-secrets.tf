resource "random_password" "django_secret_key" {
  length  = 64
  special = true
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "projectsdb-app-secrets"
    namespace = var.namespace
  }

  data = {
    django_secret_key = random_password.django_secret_key.result
  }
}
