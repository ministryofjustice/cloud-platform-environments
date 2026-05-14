resource "random_password" "django_secret_key" {
  length  = 64
  special = true
}

resource "random_password" "admin_password" {
  length  = 32
  special = true
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "projectsdb-app-secrets"
    namespace = var.namespace
  }

  data = {
    django_secret_key         = random_password.django_secret_key.result
    django_superuser_username = "admin"
    django_superuser_email    = "admin@justice.gov.uk"
    django_superuser_password = random_password.admin_password.result
  }
}
