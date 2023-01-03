provider "pingdom" {}

resource "pingdom_check" "search-api-check" {
  type                     = "http"
  name                     = "${var.application} API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/probation-offender-search.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233] # probation-integration-notifications
}
