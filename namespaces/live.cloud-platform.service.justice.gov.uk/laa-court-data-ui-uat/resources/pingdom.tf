provider "pingdom" {
}

resource "pingdom_check" "laa-court-data-ui-uat" {
  type                     = "http"
  name                     = "View court data UAT - ping"
  host                     = "uat.${var.domain}"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  integrationids           = [94703]
}

