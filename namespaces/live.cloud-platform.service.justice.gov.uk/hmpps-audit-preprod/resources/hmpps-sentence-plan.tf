resource "kubernetes_secret" "hmpps-sentence-plan-secret" {
  metadata {
    name      = "hmpps-sqs-audit-queue"
    namespace = "hmpps-sentence-plan-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
