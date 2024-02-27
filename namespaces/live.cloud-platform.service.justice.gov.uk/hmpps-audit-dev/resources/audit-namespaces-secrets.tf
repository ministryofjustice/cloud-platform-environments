
locals {
  namespaces = toset([
    "hmpps-audit-poc-ui-dev",
    "hmpps-auth-dev",
    "hmpps-authorization-server-dev",
    "hmpps-external-users-api-dev",
    "hmpps-auth-stage"
  ])
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
