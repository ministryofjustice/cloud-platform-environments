provider "pingdom" {
}

# Integration IDs
# 96624  = #dps_alerts
# 126838 = #dps_sed_alerts

resource "pingdom_check" "pathfinder-api-production-check" {
  type                     = "http"
  name                     = "DPS - Pathfinder API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/api.pathfinder.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 126838]
}

resource "pingdom_check" "pathfinder-ui-production-check" {
  type                     = "http"
  name                     = "DPS - Pathfinder UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/pathfinder.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 126838]
}
