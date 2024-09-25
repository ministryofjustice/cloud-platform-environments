
provider "pingdom" {
}

# Integration IDs
# 122531 = #prison-visit-booking-alerts

resource "pingdom_check" "prison-visits-booking-public-production" {
  type                     = "http"
  name                     = "Prison Visits Public production - Healthcheck"
  host                     = "prisonvisits.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [122531]
}

