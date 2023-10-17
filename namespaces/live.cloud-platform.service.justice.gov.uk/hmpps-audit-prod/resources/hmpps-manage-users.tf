resource "kubernetes_secret" "hmpps_manage_users_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "hmpps-manage-users-prod"
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
