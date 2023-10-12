provider "pingdom" {
}

# Integration IDs
# 132037 = #hmpps-sre-alerts

resource "pingdom_check" "sre-developer-portal-production-check" {
  type                     = "http"
  name                     = "SRE Developer Portal"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/developer-portal.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [132037]
}
