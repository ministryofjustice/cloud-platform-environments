resource "kubernetes_secret" "integration-api-secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "hmpps-integration-api-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
