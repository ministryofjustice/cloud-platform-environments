resource "kubernetes_secret" "assess-risks-and-needs-secret" {
  metadata {
    name      = "hmpps-sqs-audit-queue"
    namespace = "hmpps-assess-risks-and-needs-preprod"
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
