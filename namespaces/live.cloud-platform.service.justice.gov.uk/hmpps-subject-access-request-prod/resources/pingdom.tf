provider "pingdom" {}

# Integration IDs
# 96624 = #dps_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-subject-access-request-api-production-check" {
  type                     = "http"
  name                     = "DPS - subject-access-request Service API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request-api.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}
resource "pingdom_check" "hmpps-subject-access-request-worker-production-check" {
  type                     = "http"
  name                     = "DPS - subject-access-request Service WORKER"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request-worker.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}

resource "pingdom_check" "hmpps-subject-access-request-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS subject-access-request Service"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/subject-access-request.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}
