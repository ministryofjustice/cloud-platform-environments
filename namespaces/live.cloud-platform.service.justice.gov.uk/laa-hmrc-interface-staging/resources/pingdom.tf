provider "pingdom" {
}

resource "pingdom_check" "laa-hmrc-interface-staging" {
  type             = "http"
  name             = "LAA HMRC Interface - Staging"
  host             = "laa-hmrc-interface-staging.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/ping"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application},laa,apply-for-legal-aid"
  probefilters     = "region:EU"
  integrationids   = [96995]
}
