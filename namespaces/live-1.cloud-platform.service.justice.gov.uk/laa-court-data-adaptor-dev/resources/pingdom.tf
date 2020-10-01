provider "pingdom" {
}

resource "pingdom_check" "laa-court-data-adaptor-dev" {
  type                     = "http"
  name                     = "LAA Court Data Adaptor - dev"
  host                     = "laa-court-data-adaptor-dev.apps.live-1.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/status"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_court-data-adaptor,component_ping,isproduction_false,environment_dev"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [104018]
}
