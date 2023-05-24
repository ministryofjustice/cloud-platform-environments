resource "pingdom_check" "laa-hmrc-interface-production" {
  type             = "http"
  name             = "LAA HMRC Interface - Production"
  host             = "laa-hmrc-interface.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/ping"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application},laa,apply-for-legal-aid"
  probefilters     = "region:EU"
  integrationids   = [96996, 129269]
}
