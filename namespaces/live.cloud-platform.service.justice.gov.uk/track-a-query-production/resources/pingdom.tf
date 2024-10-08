################################################################################
# Track a Query (Correspondence Tool Staff)
# Pingdom check for uptime monitoring
#################################################################################

provider "pingdom" {}

resource "pingdom_check" "track-a-query-production-healthcheck" {
  type                     = "http"
  name                     = "Track a Query Production - healthcheck"
  host                     = "track-a-query.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_central_digital,application_track_a_query,component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_track_a_query"
  probefilters             = "region:EU"
  integrationids           = [110157, 98672]
}
