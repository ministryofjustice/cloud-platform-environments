provider "pingdom" {
}

resource "pingdom_check" "laa-estimate-financial-eligibility-for-legal-aid-staging" {
  type             = "http"
  name             = "Check if your client qualifies for legal aid - staging - ping"
  host             = "estimate-financial-eligibility-staging.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  notifyagainevery = 0
  url              = "/"
  encryption       = true
  port             = 443
  tags             = "businessunit_laa,application_check-client-qualifies-for-legal-aid,component_ping,isproduction_false,environment_staging,infrastructuresupport_check-client-qualifies-for-legal-aid,laa,check-client-qualifies-for-legal-aid"
  probefilters     = "region:EU"
}
