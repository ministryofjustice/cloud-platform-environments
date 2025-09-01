
locals {
  namespaces = toset([
    "hmpps-activities-management-dev",
    "hmpps-assess-risks-and-needs-dev",
    "hmpps-assess-risks-and-needs-integrations-dev",
    "hmpps-assess-risks-and-needs-integrations-test",
    "hmpps-assessments-dev",
    "hmpps-auth-dev",
    "hmpps-auth-stage",
    "hmpps-audit-poc-dev",
    "hmpps-book-a-video-link-dev",
    "hmpps-community-accommodation-dev",
    "hmpps-court-register-dev",
    "hmpps-external-users-api-dev",
    "hmpps-manage-users-dev",
    "hmpps-registers-dev",
    "hmpps-subject-access-request-dev"
  ])
}

resource "kubernetes_secret" "hmpps_audit_sqs_secret" {
  for_each = local.namespaces
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = each.value
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}
