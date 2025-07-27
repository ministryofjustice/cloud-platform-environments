provider "pingdom" {}

resource "pingdom_check" "pingdom_api" {
  type                     = "http"
  name                     = "HMPPS CSIP API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/csip-api.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-challenge-support-intervention-plan-api,hmpps-csip-api,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [144102] # maintenance-alerts-prod
}

resource "pingdom_check" "pingdom_ui" {
  type                     = "http"
  name                     = "HMPPS CSIP UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/csip.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-challenge-support-intervention-plan-ui,hmpps-csip-ui,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [144102] # maintenance-alerts-prod
}
