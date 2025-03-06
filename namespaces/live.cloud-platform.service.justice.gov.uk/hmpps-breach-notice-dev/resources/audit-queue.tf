locals {
  audit_queue_name = "Digital-Prison-Services-${var.environment_name}-hmpps_audit_queue"
}

resource "kubernetes_secret" "hmpps_audit_config" {
  metadata {
    namespace = var.namespace
    name      = "hmpps-audit"
  }
  data = {
    sqs_queue_url  = "https://sqs.eu-west-2.amazonaws.com/754256621582/${local.audit_queue_name}"
    sqs_queue_name = local.audit_queue_name
  }
}
