provider "pingdom" {
}

# Integration IDs
# 126335 = #elp_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-welcome-to-prison-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS WPIP API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/welcome-api.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126335, 96628]
}

resource "pingdom_check" "hmpps-welcome-to-prison-ui-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS WPIP UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/welcome.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126335, 96628]
}
