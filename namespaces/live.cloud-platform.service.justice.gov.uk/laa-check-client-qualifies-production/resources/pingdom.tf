provider "pingdom" {
}

resource "pingdom_check" "laa-check-client-qualifies-production" {
  type             = "http"
  name             = "Check if your client qualifies for legal aid - production - ping"
  host             = "check-your-client-qualifies-for-legal-aid.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_laa,application_check-client-qualifies-for-legal-aid,component_ping,isproduction_true,environment_production,infrastructuresupport_check-client-qualifies-for-legal-aid,laa,check-client-qualifies-for-legal-aid"
  probefilters     = "region:EU"
  integrationids   = [125952, 135034]
}

resource "pingdom_check" "laa-check-client-qualifies-public-production" {
  type             = "http"
  name             = "Check if your client qualifies for legal aid - public production - ping"
  host             = "check-your-client-qualifies-for-legal-aid.service.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_laa,application_check-client-qualifies-for-legal-aid,component_ping,isproduction_true,environment_production,infrastructuresupport_check-client-qualifies-for-legal-aid,laa,check-client-qualifies-for-legal-aid,laa_production_environment_dashboard"
  probefilters     = "region:EU"
  integrationids   = [125952, 135034]
}
