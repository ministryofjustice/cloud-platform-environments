provider "pingdom" {
}

# Integration IDs
# 126338 = #farsight-alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-activities-management-ui-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Activities Management Frontend - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/activities.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126338, 96628]
}

resource "pingdom_check" "hmpps-activities-management-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Activities Management API - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/activities-api.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [126338, 96628]
}
