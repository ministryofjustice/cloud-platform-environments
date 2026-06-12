provider "pingdom" {
}

resource "pingdom_check" "laa-crown-court-remuneration-dev" {
  type                     = "http"
  name                     = "Crown court remuneration dev"
  host                     = "ccr-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ccr/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${lower(var.business_unit)},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = [135401]
}
