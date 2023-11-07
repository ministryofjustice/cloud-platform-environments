provider "pingdom" {
}

resource "pingdom_check" "hmpps-digital-prison-services-preprod-check" {
  type                     = "http"
  name                     = "HMPPS Digital Prison Services - PREPROD"
  host                     = "dps-preprod.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-digital-prison-services,component_healthcheck,isproduction_false,environment_preprod"
  probefilters             = "region:EU"
  integrationids           = [132508] #connect-dps-non-prod-alerts
}
