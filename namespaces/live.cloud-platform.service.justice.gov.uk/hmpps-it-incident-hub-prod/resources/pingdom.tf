provider "pingdom" {
}

# Integration IDs
# 128422 = #product_support_alerts

resource "pingdom_check" "hmpps-it-incident-hub-production-check" {
  type                     = "http"
  name                     = "IT Incident Hub"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/it-incident-hub.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [128422]
}
