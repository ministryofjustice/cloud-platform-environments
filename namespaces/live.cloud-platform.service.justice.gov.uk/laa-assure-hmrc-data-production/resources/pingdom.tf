provider "pingdom" {
}

resource "pingdom_check" "laa-assure-hmrc-data-production-healthcheck" {
  type                     = "http"
  name                     = "${var.namespace}-healthcheck - ${var.environment} - cloud-platform"
  host                     = "check-clients-details-using-hmrc-data.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.repo_name},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = [121629]
}