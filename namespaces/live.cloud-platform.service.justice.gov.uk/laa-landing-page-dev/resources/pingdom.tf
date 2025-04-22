provider "pingdom" {
}

resource "pingdom_check" "laa-landing-page-dev" {
  type                     = "http"
  name                     = "laa-landing-page - dev - cloud-platform"
  host                     = "laa-landing-page-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.namespace},isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.namespace}"
  probefilters             = "region:EU"
  integrationids           = [142729]
}