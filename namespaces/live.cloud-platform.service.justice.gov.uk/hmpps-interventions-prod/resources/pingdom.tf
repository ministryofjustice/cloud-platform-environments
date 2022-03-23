provider "pingdom" {
}

# integration IDs:
# 114225 = Slack #interventions-alerts

resource "pingdom_check" "interventions-prod-check" {
  type                     = "http"
  name                     = "HMPPS - refer-monitor-intervention UI"
  host                     = "refer-monitor-intervention.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [114225]
}

resource "pingdom_check" "interventions-prod-service-check" {
  type                     = "http"
  name                     = "HMPPS - refer-monitor-intervention API"
  host                     = "hmpps-interventions-service.apps.live-1.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [114225]
}
