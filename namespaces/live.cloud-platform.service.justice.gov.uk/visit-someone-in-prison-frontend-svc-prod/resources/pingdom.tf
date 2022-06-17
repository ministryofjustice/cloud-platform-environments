provider "pingdom" {
}

# Integration IDs
# 122531 = #prison-visit-booking-alerts

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
  integrationids           = [122531]
}
