provider "pingdom" {
}

resource "pingdom_check" "laa-estimate-financial-eligibility-for-legal-aid-production" {
  type             = "http"
  name             = "Check if your client qualifies for legal aid - production - ping"
  host             = "check-client-qualifies-for-legal-aid.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_laa,application_check-client-qualifies-for-legal-aid,component_ping,isproduction_true,environment_production,infrastructuresupport_check-client-qualifies-for-legal-aid,laa,check-client-qualifies-for-legal-aid"
  probefilters     = "region:EU"
  integrationids   = [125952]
}
