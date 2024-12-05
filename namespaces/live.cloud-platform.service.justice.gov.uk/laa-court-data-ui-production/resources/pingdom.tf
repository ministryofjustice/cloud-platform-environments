provider "pingdom" {
}

resource "pingdom_check" "laa-court-data-ui-production" {
  type                     = "http"
  name                     = "View court data production - ping"
  host                     = var.domain
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.application},laa_production_environment_dashboard"
  probefilters             = "region:EU"
  integrationids           = [94703]
}

