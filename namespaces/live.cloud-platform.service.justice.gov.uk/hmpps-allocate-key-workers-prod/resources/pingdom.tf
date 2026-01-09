provider "pingdom" {}

resource "pingdom_check" "pingdom_ui" {
  type                     = "http"
  name                     = "HMPPS Allocate Key Workers UI"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/allocate-key-workers.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "hmpps,cloudplatform-managed,hmpps-allocate-key-workers-ui,isproduction_true"
  probefilters             = "region:EU"
  integrationids           = [144102] # maintenance-alerts-prod
}
