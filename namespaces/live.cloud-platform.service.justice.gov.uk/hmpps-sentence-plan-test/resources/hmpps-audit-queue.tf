resource "kubernetes_secret" "hmpps_audit_queue_secret" {
  metadata {
    name      = "hmpps-sqs-audit-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_name = "Digital-Prison-Services-dev-hmpps_audit_queue"
    sqs_queue_url  = "https://sqs.eu-west-2.amazonaws.com/754256621582/Digital-Prison-Services-dev-hmpps_audit_queue"
  }
}
