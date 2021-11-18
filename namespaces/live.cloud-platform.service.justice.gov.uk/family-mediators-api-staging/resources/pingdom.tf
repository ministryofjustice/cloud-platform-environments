
provider "pingdom" {
}

resource "pingdom_check" "family-mediators-api-staging-pingdom" {
  type                     = "http"
  name                     = "Family Mediators API - Staging"
  host                     = "family-mediators-api-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 60
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},component_ping,isproduction_${var.is_production},environment_${var.environment_name},cloudplatform-managed,crossjustice,api"
  probefilters             = "region:EU"
  integrationids           = [87620]
  teamids                  = [385932]
}
