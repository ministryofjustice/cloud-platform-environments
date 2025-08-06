resource "kubernetes_secret" "approved_audit_user_client_arns_send" {
    metadata {
        name = "approved-audit-user-client-arns-send"
        namespace = var.namespace
    }

    data = {
        hmpps-audit-api-irsa-arn = module.hmpps-audit-api-irsa.role_arn
        hmpps-audit-users-dead-letter-queue-arn = module.hmpps_audit_users_dead_letter_queue.sqs_arn
  }
}

resource "kubernetes_secret" "approved_audit_user_client_arns_read" {
    metadata {
        name = "approved-audit-user-client-arns-read"
        namespace = var.namespace
    }

    data = {
        hmpps-audit-api-irsa-arn = module.hmpps-audit-api-irsa.role_arn
        hmpps-audit-users-dead-letter-queue-arn = module.hmpps_audit_users_dead_letter_queue.sqs_arn
  }
}