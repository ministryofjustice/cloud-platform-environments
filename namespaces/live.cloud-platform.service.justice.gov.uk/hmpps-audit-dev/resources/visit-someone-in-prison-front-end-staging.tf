resource "kubernetes_secret" "vsip_audit_secret_staging" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "visit-someone-in-prison-frontend-svc-staging"
  }

  data = {
    sqs_queue_url     = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_queue.sqs_name
  }
}

