provider "pingdom" {}

resource "pingdom_check" "pingdom" {
  for_each = toset([
    "approved-premises-and-delius",
    "approved-premises-and-oasys",
    "custody-key-dates-and-delius",
    "make-recall-decisions-and-delius",
    "manage-pom-cases-and-delius",
    "offender-events-and-delius",
    "pre-sentence-reports-to-delius",
    "prison-case-notes-to-probation",
    "prison-custody-status-to-delius",
    "refer-and-monitor-and-delius",
    "risk-assessment-scores-to-delius",
    "tier-to-delius",
    "unpaid-work-and-delius",
    "workforce-allocations-to-delius",
    "create-and-vary-a-licence-and-delius",
    "court-case-and-delius",
    "effective-proposal-framework-and-delius",
    "sentence-plan-and-delius",
    "pathfinder-and-delius",
    "soc-and-delius",
    "sentence-plan-and-oasys",
    "domain-events-and-delius",
    "external-api-and-delius",
    "manage-offences-and-delius",
    "resettlement-passport-and-delius",
    "prison-education-and-delius",
    "arns-and-oasys",
    "opd-and-delius",
    "hmpps-auth-and-delius",
    "dps-and-delius",
    "arns-and-delius",
    "cas3-and-delius",
    "hdc-licences-and-delius",
    "prisoner-profile-and-delius",
    "prison-identifier-and-delius",
    "assessment-summary-and-delius",
    "cas2-and-delius",
    "accredited-programmes-and-oasys",
    "manage-supervision-and-oasys",
    "oasys-and-delius",
    "probation-search-and-delius",
    "core-person-record-and-delius",
    "subject-access-requests-and-delius",
    "common-platform-and-delius",
    "ims-and-delius",
    "appointment-reminders-and-delius",
    "justice-email-and-delius",
    "assess-for-early-release-and-delius",
    "breach-notice-and-delius",
    "jitbit-and-delius",
    "find-and-refer-and-delius",
    "accredited-programmes-and-delius",
    "hmpps-libra-event-receiver",
    "hmpps-common-platform-event-receiver",
    "suicide-risk-form-and-delius",
    "esupervision-and-delius",
    # ^ add new projects here
  ])
  type                     = "http"
  name                     = "Integration - ${each.value}"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/${each.value}.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233] # probation-integration-notifications
}

resource "pingdom_check" "service-endpoint-check" {
  for_each = toset([
    "manage-supervision-and-delius"
    ])
  type                     = "http"
  name                     = "Integration - ${each.value}"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/http/${each.value}.hmpps-probation-integration-services-prod.svc.cluster.local"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233] # probation-integration-notifications
}