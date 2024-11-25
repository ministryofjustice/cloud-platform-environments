provider "pingdom" {
}

# Integration IDs
# 126478 = #syscon-alerts

resource "pingdom_check" "dps-production-check" {
  type                     = "http"
  name                     = "DPS - hmpps-hpa"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/hpa.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126478]
}

