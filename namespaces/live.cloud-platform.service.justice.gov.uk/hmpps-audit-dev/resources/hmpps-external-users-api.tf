
locals {
  namespaces = {
    namespace = "hmpps-external-users-api-dev",
    namespace = "hmpps-auth-dev",
    namespace = "hmpps-authorization-server",
  }
}

resource "kubernetes_secret" "hmpps_audit_sqs_secret" {
  for_each = local.namespaces
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = each.value
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
