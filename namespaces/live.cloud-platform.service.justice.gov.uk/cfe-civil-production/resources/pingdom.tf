provider "pingdom" {
}

resource "pingdom_check" "cfe-civil-production" {
  type                     = "http"
  name                     = "Eligibility Platform - CFE Civil PRODUCTION - ping"
  host                     = "cfe-civil.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/status"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_platforms,laa_production_environment_dashboard"
  probefilters             = "region:EU"
  integrationids           = [128721]
}
