
locals {
  namespaces = toset([
    "hmpps-activities-management-prod",
    "hmpps-arns-assessment-platform-prod",
    "hmpps-assess-risks-and-needs-integrations-prod",
    "hmpps-assess-risks-and-needs-prod",
    "hmpps-assessments-prod",
    "hmpps-book-a-video-link-prod",
    "hmpps-community-accommodation-prod",
    "hmpps-contacts-prod",
    "hmpps-digital-prison-services-prod",
    "hmpps-education-and-work-plan-prod",
    "hmpps-education-employment-prod",
    "hmpps-electronic-monitoring-datastore-prod",
    "hmpps-external-users-api-prod",
    "hmpps-incentives-prod",
    "hmpps-integration-api-prod",
    "hmpps-jobs-board-prod",
    "hmpps-locations-inside-prison-prod",
    "hmpps-manage-adjudications-api-prod",
    "hmpps-manage-users-prod",
    "hmpps-managing-prisoner-apps-prod",
    "hmpps-non-associations-prod",
    "hmpps-prisoner-from-nomis-migration-prod",
    "hmpps-prisoner-profile-prod",
    "hmpps-registers-prod",
    "hmpps-subject-access-request-prod",
    "hmpps-support-additional-needs-prod",
    "hmpps-workload-prod",
    "make-recall-decision-prod",
    "visit-someone-in-prison-frontend-svc-prod"
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
