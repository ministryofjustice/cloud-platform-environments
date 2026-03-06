provider "pingdom" {
}

resource "pingdom_check" "laa-amend-a-claim-dev-pingdom" {
  type             = "http"
  name             = "${var.application} ${var.environment} - ping"
  host             = "laa-amend-a-claim-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution       = 1
  notifywhenbackup = true
  sendnotificationwhendown = 6
  notifyagainevery = 0
  url              = "/ping"
  encryption       = true
  port             = 443
  tags             = "businessunit_${var.business_unit},application_${var.namespace},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.team_name}"
  probefilters     = "region:EU"
  integrationids   = [146737]
}
