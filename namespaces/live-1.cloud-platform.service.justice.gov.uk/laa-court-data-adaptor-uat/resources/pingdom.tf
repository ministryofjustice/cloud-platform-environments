provider "pingdom" {
}

resource "pingdom_check" "laa-court-data-adaptor-uat" {
  type                     = "http"
  name                     = "LAA Court Data Adaptor - UAT"
  host                     = "laa-court-data-adaptor-uat.apps.live-1.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/status"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_court-data-adaptor,component_ping,isproduction_false,environment_uat"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [104018]
}
