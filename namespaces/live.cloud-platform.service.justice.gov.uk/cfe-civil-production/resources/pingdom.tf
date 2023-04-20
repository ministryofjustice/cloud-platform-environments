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
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [128721]
}
