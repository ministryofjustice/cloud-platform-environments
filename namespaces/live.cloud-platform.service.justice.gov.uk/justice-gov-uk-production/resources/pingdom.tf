provider "pingdom" {
}

resource "pingdom_check" "justice-gov-uk-production" {
  type                     = "http"
  name                     = "justice-gov-uk-production"
  host                     = "www.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 1 # Notify after 1 minute of downtime.
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${var.business_unit},application_${var.application},component_ping,isproduction_${var.is_production},environment_${var.environment-name},infrastructuresupport_${var.application}"
  probefilters             = "region:EU"
  integrationids           = [133317]
}
