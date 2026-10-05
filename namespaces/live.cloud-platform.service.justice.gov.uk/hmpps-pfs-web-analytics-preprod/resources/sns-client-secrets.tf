resource "kubernetes_secret" "sns_secrets" {
  for_each = toset(var.additional_topic_clients)
  metadata {
    name      = "hmpps-pfs-web-analytics-sns"
    namespace = each.value
  }
  data = {
    common_arn = module.hmpps-pfs-common.topic_arn,
    audit_arn = module.hmpps-pfs-audit.topic_arn,
    analytics_arn = module.hmpps-pfs-analytics.topic_arn
  }
}