provider "pingdom" {
}

resource "pingdom_check" "api-get-legal-aid-data-dev" {
  type                     = "http"
  name                     = "api get legal aid data - dev - cloud platform"
  host                     = "dev-laa-get-payments-finance-data.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_glad,component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_glad"
  probefilters             = "region:EU"
  integrationids           = [141868]
}
