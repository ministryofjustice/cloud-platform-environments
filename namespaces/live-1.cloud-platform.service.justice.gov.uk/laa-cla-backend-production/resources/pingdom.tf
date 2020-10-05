provider "pingdom" {
}

resource "pingdom_check" "laa-cla-backend-pingdom" {
  type                     = "http"
  name                     = "cla-backend - production - cloud-platform"
  host                     = "fox.civillegaladvice.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 1
  notifyagainevery         = 0
  url                      = "/status/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business-unit},application_cla-backend,component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_cla-backend"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [107761]
}