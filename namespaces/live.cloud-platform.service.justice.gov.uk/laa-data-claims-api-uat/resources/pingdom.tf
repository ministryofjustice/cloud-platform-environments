provider "pingdom" {
}

resource "pingdom_check" "laa-data-claims-api-uat" {
  type                     = "http"
  name                     = "${var.application} - ${var.environment} - ping"
  host                     = "main-${var.namespace}.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.repo_name},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name},laa,dstew_payments,laa_production_environment_dashboard"
  probefilters             = "region:EU"
  integrationids           = [144100]
}
