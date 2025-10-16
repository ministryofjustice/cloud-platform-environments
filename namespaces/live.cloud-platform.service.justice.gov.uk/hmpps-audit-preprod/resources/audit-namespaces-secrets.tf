
locals {
  namespaces = toset([
    "hmpps-activities-management-preprod",
    "hmpps-arns-assessment-platform-preprod",
    "hmpps-assess-risks-and-needs-integrations-preprod",
    "hmpps-assess-risks-and-needs-preprod",
    "hmpps-assessments-preprod",
    "hmpps-book-a-video-link-preprod",
    "hmpps-community-accommodation-preprod",
    "hmpps-contacts-preprod",
    "hmpps-digital-prison-services-preprod",
    "hmpps-education-and-work-plan-preprod",
    "hmpps-education-employment-preprod",
    "hmpps-electronic-monitoring-datastore-preprod",
    "hmpps-external-users-api-preprod",
    "hmpps-incentives-preprod",
    "hmpps-integration-api-preprod",
    "hmpps-jobs-board-preprod",
    "hmpps-locations-inside-prison-preprod",
    "hmpps-manage-adjudications-api-preprod",
    "hmpps-manage-users-preprod",
    "hmpps-managing-prisoner-apps-preprod",
    "hmpps-non-associations-preprod",
    "hmpps-prisoner-from-nomis-migration-preprod",
    "hmpps-prisoner-profile-preprod",
    "hmpps-registers-preprod",
    "hmpps-subject-access-request-preprod",
    "hmpps-support-additional-needs-preprod",
    "hmpps-workload-preprod",
    "make-recall-decision-preprod",
    "visit-someone-in-prison-frontend-svc-preprod"
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
