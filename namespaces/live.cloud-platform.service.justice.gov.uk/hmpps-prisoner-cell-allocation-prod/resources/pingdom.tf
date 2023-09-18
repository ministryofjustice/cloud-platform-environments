provider "pingdom" {
}

# Integration IDs
# 126335 = #elp_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-prisoner-cell-allocation-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Prisoner Cell Allocation API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/prisoner-cell-allocation-api.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126335, 96628]
}
