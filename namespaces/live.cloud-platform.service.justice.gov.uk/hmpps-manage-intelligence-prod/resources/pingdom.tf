provider "pingdom" {
}

resource "pingdom_check" "transformer" {
  type                     = "http"
  name                     = "DPS - ${var.application} - transformer"
  host                     = "mercury-data-transform-load.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [135630]
}

resource "pingdom_check" "manage-intelligence" {
  type                     = "http"
  name                     = "DPS - ${var.application}"
  host                     = "manage-intelligence.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [135630]
}

resource "pingdom_check" "manage-intelligence-api" {
  type                     = "http"
  name                     = "DPS - ${var.application} - api"
  host                     = "manage-intelligence-api.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [135630]
}