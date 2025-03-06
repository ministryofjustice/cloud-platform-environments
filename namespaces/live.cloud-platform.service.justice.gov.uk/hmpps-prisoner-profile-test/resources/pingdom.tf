provider "pingdom" {
}

resource "pingdom_check" "hmpps-prisoner-profile-test-check" {
  type                     = "http"
  name                     = "HMPPS Prisoner Profile - DEV"
  host                     = "prisoner-test.digital.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-prisoner-profile,component_healthcheck,isproduction_false,environment_dev"
  probefilters             = "region:EU"
  integrationids           = [132508] #connect-dps-non-prod-alerts
}
