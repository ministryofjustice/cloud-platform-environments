provider "pingdom" {
}

resource "pingdom_check" "hmpps-digital-prison-services-prod-check" {
  type                     = "http"
  name                     = "HMPPS Digital Prison Services - PROD"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/dps.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-digital-prison-services,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [132509] #connect-dps-prod-alerts
}
