provider "pingdom" {
}

resource "pingdom_check" "laa-status-dashboard-production-healthcheck" {
  type                     = "http"
  name                     = "LAA Status Dashboard - Production"
  host                     = "laa-status-dashboard.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 2
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.namespace},component_ping,isproduction_${var.is_production},environment_production,infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = [129414]
}
