resource "kubernetes_secret" "hmpps_person_on_probation_audit_queue_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url = "https://sqs.eu-west-2.amazonaws.com/754256621582/Digital-Prison-Services-dev-hmpps_person_on_probation_audit_queue"
  }
}