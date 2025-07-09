provider "pingdom" {
}

resource "pingdom_check" "laa-data-stewardship-civil-claims-api-uat" {
  type                     = "http"
  name                     = "${var.application} - ${var.environment} - ping"
  host                     = "main-${var.namespace}-uat.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.repo_name},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = []
}
