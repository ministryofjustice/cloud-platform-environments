resource "kubernetes_secret" "hmpps_alerts_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "hmpps-alerts-${var.environment-name}"
  }

  data = {
    sqs_queue_url   = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn   = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name  = module.hmpps_audit_queue.sqs_name
    irsa_policy_arn = module.hmpps_audit_queue.irsa_policy_arn
  }
}
