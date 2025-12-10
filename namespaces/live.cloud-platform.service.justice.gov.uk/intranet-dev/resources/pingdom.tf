provider "pingdom" {
}

resource "pingdom_check" "intranet-dev" {
  type                     = "http"
  name                     = "intranet-dev"
  host                     = "dev.intranet.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isdev_${var.is_dev},environment_${var.environment},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  integrationids           = [133317]
}
