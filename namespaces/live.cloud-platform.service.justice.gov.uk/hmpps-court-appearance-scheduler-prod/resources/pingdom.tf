provider "pingdom" {}

resource "pingdom_check" "pingdom_api" {
  type                     = "http"
  name                     = "HMPPS Court Appearance Scheduler API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/court-appearance-scheduler-api.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-court-appearance-scheduler-api,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [136330] # move-and-improve-alerts
}

resource "pingdom_check" "pingdom_ui" {
  type                     = "http"
  name                     = "HMPPS Court Appearance Scheduler UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/court-appearance-scheduler.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-court-appearance-scheduler-ui,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [136330] # move-and-improve-alerts
}