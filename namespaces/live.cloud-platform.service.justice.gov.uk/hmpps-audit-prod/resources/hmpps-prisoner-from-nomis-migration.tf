
resource "kubernetes_secret" "prisoner-from-nomis-migration_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "hmpps-prisoner-from-nomis-migration-prod"
  }

  data = {
    access_key_id     = module.hmpps_audit_queue.access_key_id
    secret_access_key = module.hmpps_audit_queue.secret_access_key
    sqs_queue_url     = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_queue.sqs_name
  }
}

