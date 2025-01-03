data "kubernetes_secret" "remote_audit_secret" {
  metadata {
    name      = "sqs-audit-queue-secret"
    namespace = "hmpps-audit-${var.environment_name}"
  }
}

resource "kubernetes_secret" "local_audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = data.kubernetes_secret.remote_audit_secret.data.sqs_queue_url
    sqs_queue_arn  = data.kubernetes_secret.remote_audit_secret.data.sqs_queue_arn
    sqs_queue_name = data.kubernetes_secret.remote_audit_secret.data.sqs_queue_name
  }
}

data "aws_ssm_parameter" "audit_irsa_policy_arn" {
  name = "/hmpps-audit-${var.environment_name}/sqs/${data.kubernetes_secret.remote_audit_secret.data.sqs_queue_name}/irsa-policy-arn"
}
