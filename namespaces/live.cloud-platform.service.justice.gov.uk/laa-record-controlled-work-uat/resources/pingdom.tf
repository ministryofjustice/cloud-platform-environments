provider "pingdom" {
}

resource "pingdom_check" "laa-record-controlled-work-rcw-uat" {
  type             = "http"
  name             = "Record controlled work (RCW) - UAT"
  host             = "record-controlled-work.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.application},component_rcw,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.application},laa,record-controlled-work"
  probefilters     = "region:EU"
  integrationids   = [148660]
}

resource "pingdom_check" "laa-record-controlled-work-ccq-uat" {
  type             = "http"
  name             = "Record controlled work (CCQ) - UAT"
  host             = "record-controlled-work.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.application},component_ccq,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.application},laa,record-controlled-work"
  probefilters     = "region:EU"
  integrationids   = [148660]
}
