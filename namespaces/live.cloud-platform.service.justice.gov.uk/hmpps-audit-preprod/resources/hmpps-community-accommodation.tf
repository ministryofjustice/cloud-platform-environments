resource "kubernetes_secret" "hmpps-community-accommodation_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "hmpps-community-accommodation-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
