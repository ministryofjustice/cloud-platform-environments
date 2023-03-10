provider "pingdom" {
}

resource "pingdom_check" "laa-cla-frontend-pingdom" {
  type                     = "http"
  name                     = "cla-frontend - production - cloud-platform"
  host                     = "cases.civillegaladvice.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/status/ready"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_cla-frontend,component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_cla-frontend"
  probefilters             = "region:EU"
  integrationids           = [107761]
}
