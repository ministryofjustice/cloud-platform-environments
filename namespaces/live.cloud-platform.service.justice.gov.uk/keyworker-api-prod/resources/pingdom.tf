provider "pingdom" {}

resource "pingdom_check" "dps-production-check" {
  type                     = "http"
  name                     = var.application
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/https/keyworker-api.prison.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed,keyworker-api,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [144102] # maintenance-alerts-prod
}

