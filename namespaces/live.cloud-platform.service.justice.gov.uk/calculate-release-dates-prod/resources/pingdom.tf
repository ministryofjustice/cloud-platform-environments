provider "pingdom" {
}

# Integration IDs
# 96624 = #dps_alerts

resource "pingdom_check" "hmpps-calculate-release-dates-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Calculate Release Dates"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/calculate-release-dates.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624]
}
