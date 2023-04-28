provider "pingdom" {
}

resource "pingdom_check" "check-financial-eligibility-production" {
  type                     = "http"
  name                     = "Check financial eligibility production - ping"
  host                     = "check-financial-eligibility.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application},laa,apply-for-legal-aid"
  probefilters             = "region:EU"
  integrationids           = [129269]
}
