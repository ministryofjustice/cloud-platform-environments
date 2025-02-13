provider "pingdom" {
}

# Integration IDs
# 141508 = #legacy-replacement-alerts-non-prod

resource "pingdom_check" "hmpps-calculate-release-dates-dev-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Calculate Release Dates Frontend - Development"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/calculate-release-dates-dev.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141508]
}
