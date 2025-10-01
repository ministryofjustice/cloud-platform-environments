
locals {
  namespaces = toset([
    "hmpps-external-users-api-preprod",
    "hmpps-activities-management-preprod",
    "hmpps-assess-risks-and-needs-preprod",
    "hmpps-assess-risks-and-needs-integrations-preprod",
    "hmpps-assessments-preprod",
    "hmpps-book-a-video-link-preprod",
    "hmpps-community-accommodation-preprod",
    "hmpps-contacts-preprod",
    "hmpps-education-and-work-plan-preprod",
    "hmpps-electronic-monitoring-datastore-preprod",
    "hmpps-incentives-preprod",
    "hmpps-integration-api-preprod",
    "hmpps-locations-inside-prison-preprod",
    "hmpps-manage-adjudications-api-preprod",
    "hmpps-manage-users-preprod",
    "hmpps-non-associations-preprod",
    "hmpps-prisoner-from-nomis-migration-preprod",
    "hmpps-prisoner-profile-preprod",
    "hmpps-registers-preprod",
    "hmpps-subject-access-request-preprod",
    "hmpps-support-additional-needs-preprod",
    "hmpps-workload-preprod",
    "make-recall-decision-preprod",
    "visit-someone-in-prison-frontend-svc-preprod",
    "hmpps-managing-prisoner-apps-preprod",
    "hmpps-jobs-board-preprod",
    "hmpps-education-employment-preprod"
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
