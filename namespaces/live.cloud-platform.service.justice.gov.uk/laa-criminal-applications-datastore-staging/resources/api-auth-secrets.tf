resource "random_password" "passwords" {
  count   = 2
  length  = 32
  special = true
}

locals {
  # Declare consumers of the API, keeping the order.
  datastore_api_consumers = {
    "crime_apply" = {
      namespace = "laa-apply-for-criminal-legal-aid-staging"
      secret    = random_password.passwords[0].result
    }
    "crime_review" = {
      namespace = "laa-review-criminal-legal-aid-staging"
      secret    = random_password.passwords[1].result
    }
  }
}

# No need to touch anything below this line. The above map
# should declare all consumers and namespaces. Code below
# will dynamically use the keys and values accordingly.

resource "kubernetes_secret" "api-auth-secrets" {
  for_each = local.datastore_api_consumers

  metadata {
    name      = "api-auth-secrets"
    namespace = var.namespace
  }

  data = {
    (each.key) = each.value.secret
  }
}

resource "kubernetes_secret" "apply-api-auth-secret" {
  for_each = local.datastore_api_consumers

  metadata {
    name      = "datastore-api-auth-secret"
    namespace = each.value.namespace
  }

  data = {
    secret = each.value.secret
  }
}
