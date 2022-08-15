resource "kubernetes_secret" "vsip_audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "visit-someone-in-prison-frontend-svc-dev"
  }

  data = {
    access_key_id     = module.hmpps_audit_queue.access_key_id
    secret_access_key = module.hmpps_audit_queue.secret_access_key
    sqs_queue_url     = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_queue.sqs_name
  }
}

