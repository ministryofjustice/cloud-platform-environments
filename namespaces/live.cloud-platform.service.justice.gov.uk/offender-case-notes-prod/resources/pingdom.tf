provider "pingdom" {
}

resource "pingdom_check" "dps-production-check" {
  type                     = "http"
  name                     = "DPS - ${var.application}"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain}"
  encryption               = true
  port                     = 443
  tags                     = "move-and-improve,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [136330] # move-and-improve
}

