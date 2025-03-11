provider "pingdom" {
}

resource "pingdom_check" "hmpps-health-and-medication-api-test-check" {
  type                     = "http"
  name                     = "HMPPS Health and Medication API - TEST"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain}"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-health-and-medication-api,component_healthcheck,isproduction_false,environment_test"
  probefilters             = "region:EU"
  integrationids           = [132508] #connect-dps-non-prod-alerts
}
