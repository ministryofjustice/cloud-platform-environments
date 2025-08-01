provider "pingdom" {
}

resource "pingdom_check" "hmpps-manage-adjudications-api-prod-check" {
  type                     = "http"
  name                     = "DPS - Manage Adjudications API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain}"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [144102] # maintenance-alerts-prod
}