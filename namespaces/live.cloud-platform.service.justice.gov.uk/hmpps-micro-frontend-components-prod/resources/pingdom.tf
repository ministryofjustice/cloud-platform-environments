provider "pingdom" {
}

resource "pingdom_check" "hmpps-micro-frontend-components-prod-check" {
  type                     = "http"
  name                     = "HMPPS Micro Frontend Components - PROD"
  host                     = "frontend-components.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-micro-frontend-components,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [132509] #connect-dps-prod-alerts
}
