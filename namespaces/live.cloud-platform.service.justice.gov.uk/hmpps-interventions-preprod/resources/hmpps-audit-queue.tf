resource "kubernetes_secret" "hmpps_audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_name = "Digital-Prison-Services-${var.environment}-hmpps_audit_queue"
    sqs_queue_url = "https://sqs.eu-west-2.amazonaws.com/754256621582/Digital-Prison-Services-${var.environment}-hmpps_audit_queue"
  }
}