provider "pingdom" {
}

resource "pingdom_check" "laa-cla-backend-pingdom" {
  type                     = "http"
  name                     = "cla-backend - training - cloud-platform"
  host                     = "training.fox.civillegaladvice.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/status/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_cla-backend,component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_cla-backend"
  probefilters             = "region:EU"
  integrationids           = [107761]
}
