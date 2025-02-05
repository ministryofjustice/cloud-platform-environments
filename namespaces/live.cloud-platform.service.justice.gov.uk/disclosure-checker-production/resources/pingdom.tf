
provider "pingdom" {
}

resource "pingdom_check" "disclosure-checker-production-pingdom" {
  type                     = "http"
  name                     = "Disclosure Checker - Production"
  host                     = "check-when-to-disclose-caution-conviction.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 60
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},component_ping,isproduction_${var.is_production},environment_${var.environment_name},cloudplatform-managed,crossjustice"
  probefilters             = "region:EU"
  integrationids           = [139912]
  teamids                  = [385932]
}
