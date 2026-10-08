resource "kubernetes_secret" "sns_secrets" {
  for_each = toset(var.additional_topic_clients)
  metadata {
    name      = "hmpps-pfs-web-analytics-sns"
    namespace = each.value
  }
  data = {
    common_arn = module.hmpps_pfs_common.topic_arn,
    audit_arn = module.hmpps_pfs_audit.topic_arn,
    analytics_arn = module.hmpps_pfs_analytics.topic_arn
  }
}

resource "kubernetes_secret" "approved_pfs_web_analytics_arns" {
    metadata {
    name = "approved-pfs-web-analytics-client-arns"
    namespace = var.namespace
  }
}

data "kubernetes_secret" "approved_pfs_web_analytics_arns" {
  metadata {
    name      = kubernetes_secret.approved_pfs_web_analytics_arns.metadata[0].name
    namespace = var.namespace
  }
}

locals {
  pfs_analytics_client_arns = [for approved_client in var.additional_topic_clients : data.kubernetes_secret.approved_pfs_web_analytics_arns.data[approved_client]]
}