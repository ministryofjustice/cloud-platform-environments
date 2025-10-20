
locals {
  namespaces = toset([
    "hmpps-activities-management-dev",
    "hmpps-arns-assessment-platform-dev",
    "hmpps-assess-risks-and-needs-dev",
    "hmpps-assess-risks-and-needs-integrations-dev",
    "hmpps-assess-risks-and-needs-integrations-test",
    "hmpps-assessments-dev",
    "hmpps-audit-poc-dev",
    "hmpps-auth-dev",
    "hmpps-auth-stage",
    "hmpps-book-a-video-link-dev",
    "hmpps-community-accommodation-dev",
    "hmpps-contacts-dev",
    "hmpps-court-register-dev",
    "hmpps-digital-prison-services-dev",
    "hmpps-document-management-dev",
    "hmpps-education-and-work-plan-dev",
    "hmpps-education-employment-dev",
    "hmpps-electronic-monitoring-datastore-dev",
    "hmpps-external-users-api-dev",
    "hmpps-incentives-dev",
    "hmpps-integration-api-dev",
    "hmpps-jobs-board-dev",
    "hmpps-locations-inside-prison-dev",
    "hmpps-manage-adjudications-api-dev",
    "hmpps-manage-users-dev",
    "hmpps-managing-prisoner-apps-dev",
    "hmpps-managing-prisoner-apps-staging",
    "hmpps-non-associations-dev",
    "hmpps-prisoner-from-nomis-migration-dev",
    "hmpps-prisoner-profile-dev",
    "hmpps-registers-dev",
    "hmpps-subject-access-request-dev",
    "hmpps-support-additional-needs-dev",
    "hmpps-workload-dev",
    "make-recall-decision-dev",
    "visit-someone-in-prison-frontend-svc-dev",
    "visit-someone-in-prison-frontend-svc-staging"
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
