provider "pingdom" {
}

# Integration IDs
# 140570 = #book-a-video-link-alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-book-a-video-link-ui-production-check" {
  type                     = "http"
  name                     = "HMPPS Book A Video Link UI - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/book-a-video-link.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [140570]
}

resource "pingdom_check" "hmpps-book-a-video-link-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Book A Video Link API - Production"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/book-a-video-link-api.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [140570, 96628]
}
