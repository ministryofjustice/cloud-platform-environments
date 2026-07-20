provider "pingdom" {}

resource "pingdom_check" "pingdom" {
  for_each = toset([
    "accredited-programmes-and-delius",
    "accredited-programmes-and-oasys",
    "appointment-reminders-and-delius",
    "approved-premises-and-delius",
    "approved-premises-and-oasys",
    "arns-and-delius",
    "arns-and-oasys",
    "assess-for-early-release-and-delius",
    "assessment-summary-and-delius",
    "breach-notice-and-delius",
    "cas2-and-delius",
    "cas3-and-delius",
    "common-platform-and-delius",
    "community-payback-and-delius",
    "core-person-record-and-delius",
    "cosso-and-delius",
    "court-case-and-delius",
    "create-and-vary-a-licence-and-delius",
    "custody-key-dates-and-delius",
    "domain-events-and-delius",
    "dps-and-delius",
    "effective-proposal-framework-and-delius",
    "esupervision-and-delius",
    "external-api-and-delius",
    "find-and-refer-and-delius",
    "hdc-licences-and-delius",
    "hmpps-auth-and-delius",
    "hmpps-common-platform-event-receiver",
    "hmpps-libra-event-receiver",
    "ims-and-delius",
    "jitbit-and-delius",
    "justice-email-and-delius",
    "make-recall-decisions-and-delius",
    "manage-my-community-sentence-and-delius",
    "manage-offences-and-delius",
    "manage-people-on-probation-and-delius",
    "manage-pom-cases-and-delius",
    "manage-supervision-and-delius",
    "manage-supervision-and-oasys",
    "oasys-and-delius",
    "offender-events-and-delius",
    "opd-and-delius",
    "pathfinder-and-delius",
    "person-search-index-from-delius",
    "pre-sentence-reports-to-delius",
    "prison-case-notes-to-probation",
    "prison-custody-status-to-delius",
    "prison-education-and-delius",
    "prison-identifier-and-delius",
    "prisoner-profile-and-delius",
    "probation-access-control",
    "probation-search-and-delius",
    "refer-and-monitor-and-delius",
    "resettlement-passport-and-delius",
    "risk-assessment-scores-to-delius",
    "sentence-plan-and-delius",
    "single-accommodation-and-delius",
    "soc-and-delius",
    "subject-access-requests-and-delius",
    "suicide-risk-form-and-delius",
    "tier-to-delius",
    "unpaid-work-and-delius",
    "warrant-risk-assessment-and-delius",
    "workforce-allocations-to-delius",
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
