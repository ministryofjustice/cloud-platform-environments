
provider "pingdom" {
}

resource "pingdom_check" "mikebell-test-check" {
  type                     = "http"
  name                     = "mikebell-test"
  host                     = "mikebell-test.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_mikebell_test,component_healthcheck,isproduction_false,environment_development,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = ["C015JL16L8Z"]
}

