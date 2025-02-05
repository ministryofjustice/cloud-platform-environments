
provider "pingdom" {
}

resource "pingdom_check" "family-mediators-api-production-pingdom" {
  type                     = "http"
  name                     = "Family Mediators API - Production"
  host                     = "familymediators.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 60
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},component_ping,isproduction_${var.is_production},environment_${var.environment_name},cloudplatform-managed,crossjustice,api"
  probefilters             = "region:EU"
  integrationids           = [139911]
  teamids                  = [385932]
}
