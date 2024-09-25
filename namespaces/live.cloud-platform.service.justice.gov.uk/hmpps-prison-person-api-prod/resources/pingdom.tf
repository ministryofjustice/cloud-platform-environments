provider "pingdom" {
}

# Integration IDs
# 126478 = #syscon-alerts

resource "pingdom_check" "prison-api-production-check" {
  type                     = "http"
  name                     = "HMPPS Prison Person API - PROD"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain}"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_hmpps-prison-person-api,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [132509] #connect-dps-prod-alerts
}
