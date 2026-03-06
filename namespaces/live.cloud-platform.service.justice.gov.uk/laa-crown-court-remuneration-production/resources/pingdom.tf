provider "pingdom" {
}

resource "pingdom_check" "laa-crown-court-remuneration-production" {
  type                     = "http"
  name                     = "Crown Court Remuneration production"
  host                     = "ccr.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ccr/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${lower(var.business_unit)},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name},laa_production_environment_dashboard"
  probefilters             = "region:EU"
  integrationids           = [138616]
}
