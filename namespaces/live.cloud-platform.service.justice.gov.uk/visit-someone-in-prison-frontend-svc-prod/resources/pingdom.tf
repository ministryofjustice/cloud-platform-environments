provider "pingdom" {
}

# Integration IDs
# 96624 = #dps_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "visit-someone-in-prison-staff-ui-production-check" {
  type                     = "http"
  name                     = "Visit Someone in Prison Staff UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/manage-prison-visits.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}
