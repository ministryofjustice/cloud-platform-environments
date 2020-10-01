provider "pingdom" {
}

resource "pingdom_check" "laa-court-data-ui-staging" {
  type                     = "http"
  name                     = "View court data staging - ping"
  host                     = "staging.${var.domain}"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [94703]
}

