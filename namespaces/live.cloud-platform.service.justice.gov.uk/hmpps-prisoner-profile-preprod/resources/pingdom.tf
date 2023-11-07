provider "pingdom" {
}

resource "pingdom_check" "hmpps-prisoner-profile-preprod-check" {
  type                     = "http"
  name                     = "HMPPS Prisoner Profile - PREPROD"
  host                     = "prisoner-preprod.digital.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-prisoner-profile,component_healthcheck,isproduction_false,environment_preprod"
  probefilters             = "region:EU"
  integrationids           = [132508] #connect-dps-non-prod-alerts
}
