provider "pingdom" {}

resource "pingdom_check" "pingdom_api" {
  type                     = "http"
  name                     = "HMPPS external-movements API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/external-movements-api.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-external-movements-api,hmpps-external-movements-api,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [136330] # move-and-improve-alerts
}

resource "pingdom_check" "pingdom_ui" {
  type                     = "http"
  name                     = "HMPPS external-movements UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/external-movements.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-external-movements-ui,hmpps-external-movements-ui,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [136330] # move-and-improve-alerts
}
