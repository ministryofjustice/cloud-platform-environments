provider "pingdom" {
}

resource "pingdom_check" "hmpps-person-communication-needs-api-prod-check" {
  type                     = "http"
  name                     = "HMPPS Person Communication Needs API - Prod"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain}"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-person-communication-needs-api,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [132509] #connect-dps-prod-alerts
}
