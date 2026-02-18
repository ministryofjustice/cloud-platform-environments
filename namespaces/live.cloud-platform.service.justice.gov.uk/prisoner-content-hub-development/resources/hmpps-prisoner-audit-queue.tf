resource "kubernetes_secret" "hmpps_prisoner_audit_queue_secret" {
  metadata {
    name      = "sqs-hmpps-prisoner-audit-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url = "https://sqs.eu-west-2.amazonaws.com/754256621582/Digital-Prison-Services-dev-hmpps_prisoner_audit_queue"
  }
}
