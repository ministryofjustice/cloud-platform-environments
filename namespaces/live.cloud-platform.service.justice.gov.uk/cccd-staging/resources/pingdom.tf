
provider "pingdom" {
}

resource "pingdom_check" "claim-crown-court-defence-staging" {
  type                     = "http"
  name                     = "Claim for crown court defence staging - ping"
  host                     = "staging.claim-crown-court-defence.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  integrationids           = [116115]
}

