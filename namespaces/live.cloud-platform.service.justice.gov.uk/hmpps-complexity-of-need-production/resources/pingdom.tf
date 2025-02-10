provider "pingdom" {
}

# Integration IDs
# 141423 = #mpc_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-cnl-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Complexity of Need"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/complexity-of-need.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141423, 96628]
}
