provider "pingdom" {
}

# Integration IDs
# 141508 = #legacy-replacement-alerts-non-prod

resource "pingdom_check" "hmpps-adjustments-pre-prod-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Adjustments Frontend - Preprod"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/adjust-release-dates-preprod.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141508]
}

resource "pingdom_check" "hmpps-adjustments-api-pre-prod-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Adjustments API - Preprod"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/adjustments-api-preprod.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [141508]
}
