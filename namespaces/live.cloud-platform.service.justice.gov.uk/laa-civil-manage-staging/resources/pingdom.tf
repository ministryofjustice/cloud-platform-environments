provider "pingdom" {
}

resource "pingdom_check" "laa-civil-manage-staging" {
  type             = "http"
  name             = "LAA Civil Manage - Staging"
  host             = "laa-civil-manage-staging.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/health"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.application},component_frontend,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application},laa,civil-manage"
  probefilters     = "region:EU"
  integrationids   = [149337]
}