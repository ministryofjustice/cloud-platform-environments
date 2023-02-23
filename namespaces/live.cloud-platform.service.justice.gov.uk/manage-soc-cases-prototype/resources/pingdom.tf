provider "pingdom" {
}

# Integration IDs
# 96624  = #dps_alerts
# 126838 = #dps_sed_alerts

resource "pingdom_check" "manage-soc-cases-api-production-check" {
  type                     = "http"
  name                     = "DPS - Manage SOC Cases API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/manage-soc-cases-api.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 126838]
}

resource "pingdom_check" "manage-soc-cases-ui-production-check" {
  type                     = "http"
  name                     = "DPS - Manage SOC Cases UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/manage-soc-cases.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 126838]
}
