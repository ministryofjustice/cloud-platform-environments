# Integration IDs
# 141228 = #visits-alerts

provider "pingdom" {
}

resource "pingdom_check" "prison-visits-booking-public-staging" {
  type                     = "http"
  name                     = "Prison Visits Public staging - Healthcheck"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                     = "/https/preprod.prisonvisits.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141228]
}

