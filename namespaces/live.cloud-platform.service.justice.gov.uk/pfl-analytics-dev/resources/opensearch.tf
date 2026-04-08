data "kubernetes_secret" "cap_opensearch" {
  metadata {
    name      = "care-arrangement-plan-opensearch-proxy-url"
    namespace = "care-arrangement-plan-dev"
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
