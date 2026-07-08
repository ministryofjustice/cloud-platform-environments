provider "pingdom" {
}

resource "pingdom_check" "intranet-staging" {
  type                     = "http"
  name                     = "intranet-staging"
  host                     = "staging.intranet.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 4
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  integrationids           = [133317]
}
