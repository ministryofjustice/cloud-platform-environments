resource "random_password" "username" {
  length  = 32
  special = false
}

resource "random_password" "password" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "ingress-basic-auth" {
  metadata {
    name      = "ingress-basic-auth"
    namespace = var.namespace
  }
  data = {
    auth = "${random_password.username.result}:${random_password.password.bcrypt_hash}"
  }
}

resource "github_actions_environment_secret" "ingress-basic-auth" {
  for_each = {
    "PERSON_SEARCH_INDEX_FROM_DELIUS_INGRESS_USERNAME" = random_password.username.result
    "PERSON_SEARCH_INDEX_FROM_DELIUS_INGRESS_PASSWORD" = random_password.password.result
  }
  repository      = data.github_repository.hmpps-probation-integration-services.name
  environment     = "prod"
  secret_name     = each.key
  plaintext_value = each.value
}
