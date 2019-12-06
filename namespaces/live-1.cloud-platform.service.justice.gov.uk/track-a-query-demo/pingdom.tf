################################################################################
# Track a Query (Correspondence Tool Staff)
# Pingdom check for uptime monitoring
#################################################################################

provider "pingdom" {}

resource "pingdom_check" "track-a-query-demo-healthcheck" {
  type                     = "http"
  name                     = "Track a Query Demo - healthcheck"
  host                     = "demo.track-a-query.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_central_digital,application_track_a_query,component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_track_a_query"
  probefilters             = "region:EU"
  publicreport             = "true"
}
