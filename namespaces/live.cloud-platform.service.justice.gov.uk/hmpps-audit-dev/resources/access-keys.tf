resource "kubernetes_secret" "additional_secrets" {
  for_each = toset(var.additional_audit_clients)
  metadata {
    name      = "hmpps-audit-queue"
    namespace = each.value
  }
  data = {
    access_key_id     = module.hmpps_audit_queue.access_key_id
    secret_access_key = module.hmpps_audit_queue.secret_access_key
    sqs_queue_url     = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_queue.sqs_name
  }
}
