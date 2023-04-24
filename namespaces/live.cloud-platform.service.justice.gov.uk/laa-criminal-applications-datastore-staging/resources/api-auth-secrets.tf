locals {
  # Declare any consumers of the API here. If any existing secrets
  # had to be rotated, change its `rotated_at` timestamp.
  datastore_api_consumers = {
    "crime_apply" = {
      namespace  = "laa-apply-for-criminal-legal-aid-staging"
      rotated_at = "2023-04-21T11:34:15Z"
    }
    "crime_review" = {
      namespace  = "laa-review-criminal-legal-aid-staging"
      rotated_at = "2023-04-21T11:34:15Z"
    }
  }
}

# No need to touch anything below this line. The above map
# should declare all consumers and namespaces. Code below
# will dynamically use the keys and values accordingly.

resource "random_password" "passwords" {
  for_each = local.datastore_api_consumers

  length  = 32
  special = true

  keepers = {
    last_changed = each.value.rotated_at
  }
}

resource "kubernetes_secret" "api-auth-secrets" {
  metadata {
    name      = "api-auth-secrets"
    namespace = var.namespace
  }

  data = {
    for key in keys(local.datastore_api_consumers) : key => random_password.passwords[key].result
  }
}

resource "kubernetes_secret" "injected-api-auth-secret" {
  for_each = local.datastore_api_consumers

  metadata {
    name      = "datastore-api-auth-secret"
    namespace = each.value.namespace
  }

  data = {
    secret = random_password.passwords[each.key].result
  }
}
