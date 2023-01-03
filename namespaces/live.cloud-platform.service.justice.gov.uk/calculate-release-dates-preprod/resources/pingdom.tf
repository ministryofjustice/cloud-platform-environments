provider "pingdom" {
}

# Integration IDs
# 126338 = #farsight-alerts

resource "pingdom_check" "hmpps-calculate-release-dates-pre-prod-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Calculate Release Dates Frontend - Preprod"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/calculate-release-dates-pre-prod.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126338]
}
