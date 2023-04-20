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
