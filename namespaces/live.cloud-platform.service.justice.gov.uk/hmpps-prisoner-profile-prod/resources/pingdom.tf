provider "pingdom" {
}

resource "pingdom_check" "hmpps-prisoner-profile-production-check" {
  type                     = "http"
  name                     = "HMPPS Prisoner Profile - PROD"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/prisoner.digital.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-prisoner-profile,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [132509] #connect-dps-prod-alerts
}
