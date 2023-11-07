provider "pingdom" {
}

resource "pingdom_check" "hmpps-micro-frontend-components-preprod-check" {
  type                     = "http"
  name                     = "HMPPS Micro Frontend Components - PREPROD"
  host                     = "frontend-components-preprod.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-micro-frontend-components,component_healthcheck,isproduction_false,environment_preprod"
  probefilters             = "region:EU"
  integrationids           = [132508] #connect-dps-non-prod-alerts
}
