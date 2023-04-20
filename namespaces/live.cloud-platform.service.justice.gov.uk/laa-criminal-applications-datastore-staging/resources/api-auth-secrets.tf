locals {
  # Declare consumers of the API with syntax: issuer = namespace
  datastore_api_consumers = {
    crime_apply  = "laa-apply-for-criminal-legal-aid-staging"
    crime_review = "laa-review-criminal-legal-aid-staging"
  }
}

# No need to touch anything below this line. The above map
# should declare all consumers and namespaces. Code below
# will dynamically use the keys and values accordingly.

resource "random_password" "passwords" {
  count   = length(local.datastore_api_consumers)
  length  = 32
  special = true
}

resource "kubernetes_secret" "api-auth-secrets" {
  for_each = local.datastore_api_consumers

  metadata {
    name      = "api-auth-secrets"
    namespace = var.namespace
  }

  data = {
    (each.key) = random_password.passwords[index(keys(local.datastore_api_consumers), each.key)].result
  }
}

resource "kubernetes_secret" "apply-api-auth-secret" {
  for_each = local.datastore_api_consumers

  metadata {
    name      = "datastore-api-auth-secret"
    namespace = each.value
  }

  data = {
    secret = kubernetes_secret.api-auth-secrets[each.key]
  }
}
