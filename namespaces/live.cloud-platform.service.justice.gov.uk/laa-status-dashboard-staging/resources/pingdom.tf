provider "pingdom" {
}

resource "pingdom_check" "laa-status-dashboard-staging-healthcheck" {
  type                     = "http"
  name                     = "LAA Status Dashboard - Staging"
  host                     = "laa-status-dashboard-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.namespace},component_ping,isproduction_${var.is_production},environment_staging,infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = [129413]
}
