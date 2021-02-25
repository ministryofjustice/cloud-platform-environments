provider "pingdom" {}

resource "pingdom_check" "dev-pk-poornima-dev-pingdom-check" {
  type                     = "http"
  name                     = "poornima-dev - cloud-platform - Healthcheck"
  host                     = "dev-pk.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_poornima_dev_app,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [111647]
}
