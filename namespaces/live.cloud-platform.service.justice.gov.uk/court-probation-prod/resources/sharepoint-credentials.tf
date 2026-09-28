resource "kubernetes_secret" "bail_information_analytics_sharepoint_credentials" {
  metadata {
    name      = "bail-information-analytics-sharepoint-credentials"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    client_id     = var.bail_information_analytics_sharepoint_client_id
    tenant_id     = var.bail_information_analytics_sharepoint_tenant_id
    client_secret = var.bail_information_analytics_sharepoint_client_secret
  }
}
