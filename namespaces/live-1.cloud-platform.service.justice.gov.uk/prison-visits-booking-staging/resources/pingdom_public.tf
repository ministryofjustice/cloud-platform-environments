terraform {
  backend "s3" {}
}

provider "pingdom" {}

resource "pingdom_check" "prison-visits-booking-public-staging" {
  type                     = "http"
  name                     = "Prison Visits Public staging - Healthcheck"
  host                     = "prison-visits-public-staging.apps.live-1.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [94618]
}
