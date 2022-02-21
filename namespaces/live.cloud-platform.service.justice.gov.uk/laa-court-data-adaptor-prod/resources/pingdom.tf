provider "pingdom" {
}

resource "pingdom_check" "laa-court-data-adaptor-prod" {
  type                     = "http"
  name                     = "LAA Court Data Adaptor - production"
  host                     = var.domain
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/status"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_court-data-adaptor,component_ping,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [104018]
}
