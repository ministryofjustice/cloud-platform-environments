data "kubernetes_secret" "cap_opensearch" {
  metadata {
    name      = "care-arrangement-plan-opensearch-proxy-url"
    namespace = "care-arrangement-plan-staging"
  }
}

resource "kubernetes_secret" "cap_opensearch_url" {
  metadata {
    name      = "cap-opensearch-url"
    namespace = var.namespace
  }

  data = {
    proxy_url = data.kubernetes_secret.cap_opensearch.data["proxy_url"]
  }
}

data "kubernetes_secret" "cs_opensearch" {
  metadata {
    name      = "connecting-services-opensearch-proxy-url"
    namespace = "connecting-services-staging"
  }
}

resource "kubernetes_secret" "cs_opensearch_url" {
  metadata {
    name      = "cs-opensearch-url"
    namespace = var.namespace
  }

  data = {
    proxy_url = data.kubernetes_secret.cs_opensearch.data["proxy_url"]
  }
}
