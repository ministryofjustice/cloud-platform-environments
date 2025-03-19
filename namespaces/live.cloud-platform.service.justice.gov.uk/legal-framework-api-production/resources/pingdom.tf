provider "pingdom" {
}

resource "pingdom_check" "legal-framework-api-production" {
  type                     = "http"
  name                     = "Legal framework api production - ping"
  host                     = "legal-framework-api.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application},laa,apply-for-legal-aid,laa_production_environment_dashboard"
  probefilters             = "region:EU"
  integrationids           = [96996, 129269]
}
