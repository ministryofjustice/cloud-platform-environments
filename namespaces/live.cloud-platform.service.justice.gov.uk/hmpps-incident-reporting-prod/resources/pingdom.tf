provider "pingdom" {}

# Integration IDs
# 96624 = #dps_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-incident-reporting-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Incident Reporting Service API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/incident-reporting-api.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}

resource "pingdom_check" "hmpps-incident-reporting-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Incident Reporting Service"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/incident-reporting.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}
