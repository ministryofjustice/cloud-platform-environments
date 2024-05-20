provider "pingdom" {
}

resource "pingdom_check" "hello-cloud-platform-app" {
  type                     = "http"
  name                     = "test-hello-cloud-platform-app"
  host                     = "aaf-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  paused                   = false
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},isproduction_${var.is_production},owner_${var.team_name}"
  probefilters             = "region:EU"
  integrationids           = [134879]
}