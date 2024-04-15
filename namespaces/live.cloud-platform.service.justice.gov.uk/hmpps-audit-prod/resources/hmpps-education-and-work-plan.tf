resource "kubernetes_secret" "education_and_work_plan_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = "hmpps-education-and-work-plan-prod"
  }

  data = {
    sqs_queue_url     = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_queue.sqs_name
  }
}
