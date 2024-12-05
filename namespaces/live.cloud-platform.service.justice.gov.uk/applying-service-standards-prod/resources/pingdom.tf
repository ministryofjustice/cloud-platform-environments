provider "pingdom" {
}

# Integration IDs
# 96624 = #dps_alerts

resource "pingdom_check" "cdpt-applying-service-standards-production-check" {
  type                     = "http"
  name                     = "Central Digital - Applying Service Standards"
  host                     = "service-standards-assurance.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "hq,central-digital,cloudplatform-managed,cdpt"
  probefilters             = "region:EU"
  #integrationids           = []
}
