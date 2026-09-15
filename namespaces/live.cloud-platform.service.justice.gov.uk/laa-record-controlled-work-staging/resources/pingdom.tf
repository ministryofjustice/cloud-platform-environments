provider "pingdom" {
}

resource "pingdom_check" "laa-record-controlled-work-rcw-staging" {
  type             = "http"
  name             = "Record controlled work (RCW) - STAGING"
  host             = "laa-record-controlled-work-staging.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/status"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.application},component_rcw,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application},laa,record-controlled-work"
  probefilters     = "region:EU"
  integrationids   = [148660]
}
