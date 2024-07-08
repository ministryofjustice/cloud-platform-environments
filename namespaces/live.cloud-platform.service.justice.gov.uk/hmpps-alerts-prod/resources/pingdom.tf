provider "pingdom" {}

resource "pingdom_check" "pingdom" {
  type                     = "http"
  name                     = "HMPPS Alerts API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/alerts-api.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-alerts-api,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [136330] # move-and-improve-alerts
}
