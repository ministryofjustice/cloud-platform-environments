provider "pingdom" {
}

resource "pingdom_check" "laa-cla-backend-pingdom" {
  type                     = "http"
  name                     = "cla-backend - staging - cloud-platform"
  host                     = "laa-cla-backend-staging.apps.live-1.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/admin"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_${var.application},component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.infrastructure-support}"
  probefilters             = "region:EU"
  publicreport             = "true"
}
