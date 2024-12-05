provider "pingdom" {
}

resource "pingdom_check" "laa-cla-public-pingdom" {
  type                     = "http"
  name                     = "cla-public - production - cloud-platform"
  host                     = "checklegalaid.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/session-expired"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_cla-public,component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_cla-public"
  probefilters             = "region:EU"
  integrationids           = [107761]
}
