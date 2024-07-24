provider "pingdom" {
}

resource "pingdom_check" "fala-staging" {
  type                     = "http"
  name                     = "fala - production - pingdom"
  host                     = "find-legal-advice.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_production,infrastructuresupport_platforms,laa_production_environment_dashboard"
  probefilters             = "region:EU"
}
