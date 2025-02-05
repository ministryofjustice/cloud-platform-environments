provider "pingdom" {
}

# Integration IDs
# 130487 = #prison-education-alerts

resource "pingdom_check" "hmpps-jobs-board-integration-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Jobs Board Integration API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain_jobs_board_integration_api}"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [130487]
}
