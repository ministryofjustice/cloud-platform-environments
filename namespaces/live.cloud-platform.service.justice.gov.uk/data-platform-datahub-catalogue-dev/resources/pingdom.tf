provider "pingdom" {
}

resource "pingdom_check" "datahub-catalogue-dev" {
  type                     = "http"
  name                     = "datahub-catalogue - dev - cloud-platform"
  host                     = "datahub-catalogue-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/admin"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.business_unit}"
  probefilters             = "region:EU"
  integrationids           = []
}
