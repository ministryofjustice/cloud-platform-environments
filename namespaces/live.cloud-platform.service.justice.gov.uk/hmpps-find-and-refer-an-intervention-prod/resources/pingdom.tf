provider "pingdom" {
}

# integration IDs:
# 114225 = Slack #interventions-alerts

resource "pingdom_check" "find-and-refer-intervention-prod-check" {
  type                     = "http"
  name                     = "hmpps-find-and-refer-an-intervention-ui"
  host                     = "find-and-refer-intervention.hmpps.service.justice.gov.uk"
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

resource "pingdom_check" "find-and-refer-intervention-prod-service-check" {
  type                     = "http"
  name                     = "hmpps-find-and-refer-an-intervention-api"
  host                     = "find-and-refer-intervention-api.hmpps.service.justice.gov.uk"
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
