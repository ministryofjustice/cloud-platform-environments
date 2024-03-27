provider "pingdom" {
}

resource "pingdom_check" "fala-staging" {
  type                     = "http"
  name                     = "fala - staging - pingdom"
  host                     = "staging.find-legal-advice.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_staging,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [134779]
}
