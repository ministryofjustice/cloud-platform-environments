
provider "pingdom" {
}

resource "pingdom_check" "elsa-relevant-search-production-pingdom" {
  type                     = "http"
  name                     = "ELSA Relevant Search - Production"
  host                     = "search-information-about-legal-problems.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 60
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},component_ping,isproduction_${var.is_production},environment_${var.environment_name},cloudplatform-managed,crossjustice"
  probefilters             = "region:EU"
  integrationids           = [87620]
  teamids                  = [385932]
}
